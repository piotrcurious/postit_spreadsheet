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

# Don't run the last part of PIspread6.tk which creates another app
regsub {if \{\[info script\] eq \$argv0\} \{.*\}} $content {} content

eval $content

# Test script
if {[info commands app] ne ""} { rename app "" }
SpreadsheetApp create app .app
app addCell .app 1
app addCell .app 10

# Set values via vars since that's how it's done in PIspread6
# In the app, they are in the [self namespace]::vars array.
# Let's find the namespace.
set ns [info object namespace app]
# Disable trace to set initial values without trigger
trace remove variable ${ns}::vars(1) write [list app onCellValueChange 1]
trace remove variable ${ns}::vars(10) write [list app onCellValueChange 10]

set ${ns}::vars(1) 10
set ${ns}::vars(10) 500

# Re-enable trace
trace add variable ${ns}::vars(1) write [list app onCellValueChange 1]
trace add variable ${ns}::vars(10) write [list app onCellValueChange 10]

app addCell .app 3
# setRelationExplicit doesn't exist anymore, it's applyRelation
app applyRelation 3 {$cell10 + $cell1} .dummyWin
puts "Cell 3 with \$cell10 + \$cell1: [set ${ns}::vars(3)]"

if {[set ${ns}::vars(3)] == 510} {
    puts "Test Passed"
} else {
    puts "Test Failed: Expected 510, got [set ${ns}::vars(3)]"
}
