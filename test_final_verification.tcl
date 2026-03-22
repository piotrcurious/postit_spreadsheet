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

# Test Case 1: Simple Addition
app addCell .app 1
app addCell .app 2
app addCell .app 3
set ${ns}::vars(1) 10
set ${ns}::vars(2) 20
app applyRelation 3 {$cell1 + $cell2} .dummy
puts "Addition test: [set ${ns}::vars(3)] (Expected 30)"

# Test Case 2: Multi-step Dependency
app addCell .app 4
app applyRelation 4 {$cell3 * 2} .dummy
puts "Chain test: [set ${ns}::vars(4)] (Expected 60)"

# Test Case 3: Update propagation
set ${ns}::vars(1) 15
# Cell 1 change should update Cell 3 (15+20=35) and Cell 4 (35*2=70)
puts "Propagation test: [set ${ns}::vars(4)] (Expected 70)"

# Test Case 4: Functions
app addCell .app 5
app applyRelation 5 {SUM($cell1, $cell2, $cell3)} .dummy
puts "SUM test: [set ${ns}::vars(5)] (Expected 70)"

# Test Case 5: Word Boundary Check ($cell1 vs $cell10)
app addCell .app 10
set ${ns}::vars(10) 1000
app addCell .app 11
app applyRelation 11 {$cell10 + 1} .dummy
puts "ID Boundary test: [set ${ns}::vars(11)] (Expected 1001)"

# Test Case 6: Deletion
app deleteCell 1
if {![info exists ${ns}::cells(1)]} {
    puts "Deletion test: Passed"
} else {
    puts "Deletion test: Failed"
}

# Summary
if {[set ${ns}::vars(11)] == 1001 && [set ${ns}::vars(4)] == 70} {
    puts "ALL TESTS PASSED"
} else {
    puts "SOME TESTS FAILED"
}
