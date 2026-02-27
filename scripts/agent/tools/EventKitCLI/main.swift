import EventKit
import Foundation
import CoreLocation

@main
struct EventKitCLI {
    static let store = EKEventStore()

    static func main() {
        let args = Array(CommandLine.arguments.dropFirst())
        guard args.count >= 2 else { printUsage(); exit(1) }

        let domain = args[0]   // "reminders" or "calendar"
        let action = args[1]   // "add", "list", "complete", "lists"
        let rest = Array(args.dropFirst(2))

        // Request access synchronously
        let sem = DispatchSemaphore(value: 0)
        var accessGranted = false

        switch domain {
        case "reminders":
            if #available(macOS 14.0, *) {
                store.requestFullAccessToReminders { granted, _ in
                    accessGranted = granted; sem.signal()
                }
            } else {
                store.requestAccess(to: .reminder) { granted, _ in
                    accessGranted = granted; sem.signal()
                }
            }
        case "calendar":
            if #available(macOS 14.0, *) {
                store.requestFullAccessToEvents { granted, _ in
                    accessGranted = granted; sem.signal()
                }
            } else {
                store.requestAccess(to: .event) { granted, _ in
                    accessGranted = granted; sem.signal()
                }
            }
        default:
            printUsage(); exit(1)
        }
        sem.wait()
        guard accessGranted else { die("Access denied. Grant permission in System Settings > Privacy > \(domain == "reminders" ? "Reminders" : "Calendars").") }

        switch (domain, action) {
        case ("reminders", "add"):     remindersAdd(rest)
        case ("reminders", "list"):    remindersList(rest)
        case ("reminders", "complete"): remindersComplete(rest)
        case ("reminders", "lists"):   remindersLists()
        case ("calendar", "add"):      calendarAdd(rest)
        case ("calendar", "list"):     calendarList(rest)
        default: printUsage(); exit(1)
        }
    }

    // MARK: - Reminders

    static func remindersAdd(_ args: [String]) {
        guard let title = args.first, !title.hasPrefix("--") else { die("Usage: eventkit-cli reminders add \"title\" [--list X] [--due ISO8601] [--lat/--lng/--radius/--proximity/--location-name]") }
        let opts = parseOpts(Array(args.dropFirst()))

        let reminder = EKReminder(eventStore: store)
        reminder.title = title

        // Find calendar/list
        if let listName = opts["list"] {
            guard let cal = store.calendars(for: .reminder).first(where: { $0.title.lowercased() == listName.lowercased() }) else {
                die("Reminder list '\(listName)' not found. Run: eventkit-cli reminders lists")
            }
            reminder.calendar = cal
        } else {
            reminder.calendar = store.defaultCalendarForNewReminders()
        }

        // Due date
        if let dueStr = opts["due"] {
            guard let date = parseDate(dueStr) else { die("Invalid date: \(dueStr). Use ISO8601.") }
            reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            let alarm = EKAlarm(absoluteDate: date)
            reminder.addAlarm(alarm)
        }

        // Location-based reminder
        if let latStr = opts["lat"], let lngStr = opts["lng"] {
            guard let lat = Double(latStr), let lng = Double(lngStr) else { die("Invalid lat/lng") }
            let radius = Double(opts["radius"] ?? "100") ?? 100
            let proximity: EKAlarmProximity = opts["proximity"] == "leave" ? .leave : .enter
            let locName = opts["location-name"] ?? "Location"

            let location = EKStructuredLocation(title: locName)
            location.geoLocation = CLLocation(latitude: lat, longitude: lng)
            location.radius = radius

            let alarm = EKAlarm()
            alarm.structuredLocation = location
            alarm.proximity = proximity
            reminder.addAlarm(alarm)
        }

        do {
            try store.save(reminder, commit: true)
            let out: [String: Any] = ["ok": true, "id": reminder.calendarItemIdentifier, "title": title]
            printJSON(out)
        } catch {
            die("Failed to save reminder: \(error.localizedDescription)")
        }
    }

    static func remindersList(_ args: [String]) {
        let opts = parseOpts(args)
        var calendars = store.calendars(for: .reminder)
        if let listName = opts["list"] {
            calendars = calendars.filter { $0.title.lowercased() == listName.lowercased() }
            if calendars.isEmpty { die("Reminder list '\(listName)' not found.") }
        }

        let predicate = store.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: calendars.isEmpty ? nil : calendars)
        let sem = DispatchSemaphore(value: 0)
        var results: [EKReminder] = []
        store.fetchReminders(matching: predicate) { reminders in
            results = reminders ?? []
            sem.signal()
        }
        sem.wait()

        let items = results.map { r -> [String: Any] in
            var d: [String: Any] = ["id": r.calendarItemIdentifier, "title": r.title ?? "", "list": r.calendar.title]
            if let dc = r.dueDateComponents, let date = Calendar.current.date(from: dc) {
                d["due"] = iso8601(date)
            }
            return d
        }
        printJSON(items)
    }

    static func remindersComplete(_ args: [String]) {
        guard let id = args.first else { die("Usage: eventkit-cli reminders complete <id>") }
        guard let item = store.calendarItem(withIdentifier: id) as? EKReminder else { die("Reminder not found: \(id)") }
        item.isCompleted = true
        do {
            try store.save(item, commit: true)
            printJSON(["ok": true, "id": id])
        } catch {
            die("Failed to complete: \(error.localizedDescription)")
        }
    }

    static func remindersLists() {
        let cals = store.calendars(for: .reminder)
        let items = cals.map { ["title": $0.title, "id": $0.calendarIdentifier] }
        printJSON(items)
    }

    // MARK: - Calendar

    static func calendarAdd(_ args: [String]) {
        guard let title = args.first, !title.hasPrefix("--") else { die("Usage: eventkit-cli calendar add \"title\" --date YYYY-MM-DD [--from HH:MM --to HH:MM | --all-day] [--calendar X]") }
        let opts = parseOpts(Array(args.dropFirst()))

        guard let dateStr = opts["date"] else { die("--date is required") }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.locale = Locale(identifier: "en_US_POSIX")
        guard let baseDate = df.date(from: dateStr) else { die("Invalid date: \(dateStr)") }

        let event = EKEvent(eventStore: store)
        event.title = title

        if let calName = opts["calendar"] {
            guard let cal = store.calendars(for: .event).first(where: { $0.title.lowercased() == calName.lowercased() }) else {
                die("Calendar '\(calName)' not found.")
            }
            event.calendar = cal
        } else {
            event.calendar = store.defaultCalendarForNewEvents
        }

        let isAllDay = opts["all-day"] != nil
        if isAllDay {
            event.isAllDay = true
            event.startDate = baseDate
            event.endDate = baseDate
        } else if let fromStr = opts["from"], let toStr = opts["to"] {
            guard let start = parseTime(fromStr, on: baseDate), let end = parseTime(toStr, on: baseDate) else {
                die("Invalid time format. Use HH:MM.")
            }
            event.startDate = start
            event.endDate = end
        } else {
            // Default to all-day if no time specified
            event.isAllDay = true
            event.startDate = baseDate
            event.endDate = baseDate
        }

        do {
            try store.save(event, span: .thisEvent)
            printJSON(["ok": true, "id": event.eventIdentifier ?? "", "title": title])
        } catch {
            die("Failed to save event: \(error.localizedDescription)")
        }
    }

    static func calendarList(_ args: [String]) {
        let opts = parseOpts(args)
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.locale = Locale(identifier: "en_US_POSIX")

        let startDate: Date
        let endDate: Date

        if opts["today"] != nil {
            startDate = Calendar.current.startOfDay(for: Date())
            endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        } else if let dateStr = opts["date"] {
            guard let d = df.date(from: dateStr) else { die("Invalid date: \(dateStr)") }
            startDate = Calendar.current.startOfDay(for: d)
            endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        } else if let fromStr = opts["from"], let toStr = opts["to"] {
            guard let f = df.date(from: fromStr), let t = df.date(from: toStr) else { die("Invalid date range") }
            startDate = Calendar.current.startOfDay(for: f)
            endDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: t))!
        } else {
            // Default: today
            startDate = Calendar.current.startOfDay(for: Date())
            endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        }

        let predicate = store.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = store.events(matching: predicate)

        let items = events.map { e -> [String: Any] in
            var d: [String: Any] = [
                "id": e.eventIdentifier ?? "",
                "title": e.title ?? "",
                "calendar": e.calendar.title,
                "allDay": e.isAllDay,
            ]
            d["start"] = iso8601(e.startDate)
            d["end"] = iso8601(e.endDate)
            return d
        }
        printJSON(items)
    }

    // MARK: - Helpers

    static func parseOpts(_ args: [String]) -> [String: String] {
        var opts: [String: String] = [:]
        var i = 0
        while i < args.count {
            let arg = args[i]
            if arg.hasPrefix("--") {
                let key = String(arg.dropFirst(2))
                // Boolean flags (no value)
                if key == "all-day" || key == "today" {
                    opts[key] = "true"
                } else if i + 1 < args.count {
                    opts[key] = args[i + 1]
                    i += 1
                }
            }
            i += 1
        }
        return opts
    }

    static func parseDate(_ s: String) -> Date? {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        if let d = f.date(from: s) { return d }
        // Try without time
        f.formatOptions = [.withFullDate]
        if let d = f.date(from: s) { return d }
        // Try basic format
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        for fmt in ["yyyy-MM-dd'T'HH:mm:ss", "yyyy-MM-dd'T'HH:mm", "yyyy-MM-dd"] {
            df.dateFormat = fmt
            if let d = df.date(from: s) { return d }
        }
        return nil
    }

    static func parseTime(_ time: String, on date: Date) -> Date? {
        let parts = time.split(separator: ":")
        guard parts.count == 2, let h = Int(parts[0]), let m = Int(parts[1]) else { return nil }
        return Calendar.current.date(bySettingHour: h, minute: m, second: 0, of: date)
    }

    static func iso8601(_ date: Date) -> String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f.string(from: date)
    }

    static func printJSON(_ value: Any) {
        if let data = try? JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted, .sortedKeys]),
           let str = String(data: data, encoding: .utf8) {
            print(str)
        }
    }

    static func die(_ msg: String) -> Never {
        FileHandle.standardError.write(Data("Error: \(msg)\n".utf8))
        exit(1)
    }

    static func printUsage() {
        let usage = """
        Usage: eventkit-cli <domain> <action> [args]

        Reminders:
          eventkit-cli reminders add "title" [--list X] [--due ISO8601] [--lat/--lng/--radius/--proximity/--location-name]
          eventkit-cli reminders list [--list X]
          eventkit-cli reminders complete <id>
          eventkit-cli reminders lists

        Calendar:
          eventkit-cli calendar add "title" --date YYYY-MM-DD [--from HH:MM --to HH:MM | --all-day] [--calendar X]
          eventkit-cli calendar list [--today | --date YYYY-MM-DD | --from YYYY-MM-DD --to YYYY-MM-DD]
        """
        FileHandle.standardError.write(Data(usage.utf8))
    }
}
