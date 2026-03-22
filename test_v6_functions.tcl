package require TclOO

# Mock Tk and json/fileutil
proc winfo {cmd args} {
    switch -- $cmd {
        exists { return 1 }
        parent { return "" }
    }
}
proc toplevel {w} { proc $w {cmd args} { }; return $w }
proc frame {w args} { proc $w {cmd args} { }; return $w }
proc label {w args} { proc $w {cmd args} { }; return $w }
array set entryValues {}
proc entry {w args} {
    global entryValues
    set entryValues($w) ""
    proc $w {cmd args} {
        global entryValues
        set w [lindex [info level 0] 0]
        switch -- $cmd {
            get { return $entryValues($w) }
            insert { set entryValues($w) [lindex $args 1] }
            delete { set entryValues($w) "" }
            configure { }
        }
    }
    return $w
}
proc button {w args} { proc $w {cmd args} { }; return $w }
proc pack {args} { }
proc grid {args} { }
proc wm {args} { }
proc destroy {w} { }
proc tk_getOpenFile {args} { return "" }
proc tk_getSaveFile {args} { return "" }
proc tk_messageBox {args} { }
proc after {delay script} { }

# Strip package require Tk from PIspread6.tk
set f [open PIspread6.tk r]
set content [read $f]
close $f
regsub {package require Tk} $content {} content
regsub {if \{\[info script\] eq \$argv0\} \{.*\}} $content {} content
eval $content

# Test script
if {[info commands app] ne ""} { rename app "" }
SpreadsheetApp create app .app
set ns [info object namespace app]

app addCell .app 1
app addCell .app 2
app addCell .app 3

set ${ns}::vars(1) 10
set ${ns}::vars(2) 20
set ${ns}::vars(3) 30

app addCell .app 4
app applyRelation 4 {SUM($cell1, $cell2, $cell3)} .dummyWin
puts "SUM test: [set ${ns}::vars(4)]"

app applyRelation 4 {AVERAGE($cell1, $cell2, $cell3)} .dummyWin
puts "AVERAGE test: [set ${ns}::vars(4)]"

if {[set ${ns}::vars(4)] == 20.0} {
    puts "Functions Test Passed"
} else {
    puts "Functions Test Failed: Expected 20.0, got [set ${ns}::vars(4)]"
}
