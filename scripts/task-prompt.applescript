use AppleScript version "2.4"
use framework "Foundation"
use framework "AppKit"
use scripting additions

set theAlert to current application's NSAlert's alloc()'s init()
theAlert's setMessageText:"New task"
set hammerImage to current application's NSImage's imageWithSystemSymbolName:"hammer" accessibilityDescription:""
set hammerConfig to current application's NSImageSymbolConfiguration's configurationWithPointSize:48 weight:(current application's NSFontWeightMedium)
set hammerImage to hammerImage's imageWithSymbolConfiguration:hammerConfig
theAlert's setIcon:hammerImage
theAlert's addButtonWithTitle:"Run"
theAlert's addButtonWithTitle:"Cancel"

set theTextView to current application's NSTextView's alloc()'s initWithFrame:(current application's NSMakeRect(0, 0, 500, 250))
theTextView's setEditable:true
theTextView's setSelectable:true
theTextView's setFont:(current application's NSFont's fontWithName:"Menlo" |size|:13)
theTextView's setRichText:false

set scrollView to current application's NSScrollView's alloc()'s initWithFrame:(current application's NSMakeRect(0, 0, 500, 250))
scrollView's setDocumentView:theTextView
scrollView's setHasVerticalScroller:true

theAlert's setAccessoryView:scrollView
theAlert's |window|()'s setInitialFirstResponder:theTextView

-- Set up Edit menu so Cmd+A/C/V/X/Z work
set editMenu to current application's NSMenu's alloc()'s initWithTitle:"Edit"
editMenu's addItemWithTitle:"Select All" action:"selectAll:" keyEquivalent:"a"
editMenu's addItemWithTitle:"Copy" action:"copy:" keyEquivalent:"c"
editMenu's addItemWithTitle:"Paste" action:"paste:" keyEquivalent:"v"
editMenu's addItemWithTitle:"Cut" action:"cut:" keyEquivalent:"x"
editMenu's addItemWithTitle:"Undo" action:"undo:" keyEquivalent:"z"
set editMenuItem to current application's NSMenuItem's alloc()'s init()
editMenuItem's setSubmenu:editMenu
set mainMenu to current application's NSMenu's alloc()'s init()
mainMenu's addItem:editMenuItem
current application's NSApp's setMainMenu:mainMenu

theAlert's |window|()'s setLevel:(current application's NSFloatingWindowLevel)
current application's NSApp's setActivationPolicy:(current application's NSApplicationActivationPolicyAccessory)
current application's NSApp's activateIgnoringOtherApps:true
set response to theAlert's runModal()
if response is not (current application's NSAlertFirstButtonReturn) then error number -128

set inputText to (theTextView's |string|()) as text
if inputText is "" then error number -128
return inputText
