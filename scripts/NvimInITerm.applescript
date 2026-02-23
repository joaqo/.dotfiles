on open theFiles
    set filePaths to ""
    repeat with f in theFiles
        set filePaths to filePaths & " " & quoted form of POSIX path of f
    end repeat

    tell application "iTerm"
        activate
        set newWindow to (create window with default profile)
        tell current session of newWindow
            write text "nvim" & filePaths
        end tell
    end tell
end open
