import * as assert from "assert"
import {insertLineAfterCurrent, moveCaretForwardTowardsNextSentence,
    deleteBackwardsTowardsSentenceStart,
    moveCaretBackwardsSentenceWise} from "../js/editor"


function convert(what) {

    const i = what.indexOf("|")
    const result = what.slice(0, i) + what.slice(i + 1, what.length)
    return [i, result]
}

describe("Editor", function() {
    
    describe("insertLineAfterCurrent", function() {

        it("cursor at start of line", function() {
            
            assert.deepEqual(
                insertLineAfterCurrent(
                    convert("|abc")), 
                convert("abc\n|"))
        })
    
        it("cursor at end of line", function() {
            
            assert.deepEqual(insertLineAfterCurrent(
                    convert("abc|")), 
                convert("abc\n|"))
        })
    
        it("cursor somewhere in the line", function() {
            
            assert.deepEqual(insertLineAfterCurrent(
                    convert("a|bc")),
                convert("abc\n|"))
        })
    })

    describe("moveCaretTowardsNextSentence", function() {

        it("base case", function() {
            
            assert.deepEqual(
                moveCaretForwardTowardsNextSentence(
                    convert("|abc.")), 
                convert("abc.|"))
        })

        it("double newline", function() {
            
            assert.deepEqual(
                moveCaretForwardTowardsNextSentence(
                    convert("|abc\n\ndef")), 
                convert("abc|\n\ndef"))
        })
 
        it("double newline, 1", function() {
            
            assert.deepEqual(
                moveCaretForwardTowardsNextSentence(
                    convert("abc|\n\ndef")), 
                convert("abc\n|\ndef"))
        })
 
        it("double newline, 2", function() {
            
            assert.deepEqual(
                moveCaretForwardTowardsNextSentence(
                    convert("|\nabc. def")), 
                convert("\nabc.| def"))
        })
    })

    describe("moveCaretBackwardsSentenceWise", function() {

        it("beginning of file", function() {
            
            assert.deepEqual(
                moveCaretBackwardsSentenceWise(
                    convert("abc|")), 
                convert("|abc"))
        })

        it("baseCase", function() {
            
            assert.deepEqual(
                moveCaretBackwardsSentenceWise(
                    convert("abc. abc|")), 
                convert("abc. |abc"))
        })

        it("baseCase, middle of sentence", function() {
            
            assert.deepEqual(
                moveCaretBackwardsSentenceWise(
                    convert("abc. ab|c")), 
                convert("abc. |abc"))
        })

        it("baseCase, caret immediately after sentenceStop", function() {
            
            assert.deepEqual(
                moveCaretBackwardsSentenceWise(
                    convert("abc. abc.|")), 
                convert("abc. |abc."))
        })

        it("interpret consecutive newlines as sentence stop", function() {
            
            assert.deepEqual(
                moveCaretBackwardsSentenceWise(
                    convert("abc\n\nabc|")), 
                convert("abc\n\n|abc"))
        })
    })

    describe("deleteBackwardsTowardsSentenceStart", function() {
        
        it("cursor at the very beginning", function() {
            
            assert.deepEqual(
                deleteBackwardsTowardsSentenceStart(
                    convert("|abc")), 
                convert("|abc"))
        })

        it("delete towards very beginning", function() {
            
            assert.deepEqual(
                deleteBackwardsTowardsSentenceStart(
                    convert("abc|")), 
                convert("|"))
        })

        it("move across one linebreak", function() {
            
            assert.deepEqual(deleteBackwardsTowardsSentenceStart(
                    convert("abc. abc\nabc|")), 
                convert("abc. |"))
        })

        it("dont move across one linebreak if ending with sentence stop", function() {
            
            assert.deepEqual(deleteBackwardsTowardsSentenceStart(
                    convert("abc. abc.\nabc|")), 
                convert("abc. abc.\n|"))
        })

        it("delete towards consecutive line breaks", function() {
            
            assert.deepEqual(
                deleteBackwardsTowardsSentenceStart(
                    convert("abc\n\nabc|")), 
                convert("abc\n\n|"))
        })

        it("remove one of consecutive line breaks", function() {
            
            assert.deepEqual(
                deleteBackwardsTowardsSentenceStart(
                    convert("abc\n\n|")), 
                convert("abc\n|"))
        })

        it("cursor at end of line", function() {
            
            assert.deepEqual(
                deleteBackwardsTowardsSentenceStart(
                    convert("abc. abc|")), 
                convert("abc. |"))
        })

        it("cursor between sentences, one whitespace", function() {
            
            assert.deepEqual(
                deleteBackwardsTowardsSentenceStart(
                    convert("abc. |abc")), 
                convert("abc.|abc"))
        })

        it("cursor between sentences, multiple whitespaces", function() {
            
            assert.deepEqual(
                deleteBackwardsTowardsSentenceStart(
                    convert("abc.  |abc")), 
                convert("abc.|abc"))
        })

        it("cursor between sentences, middle of word", function() {
            
            assert.deepEqual(
                deleteBackwardsTowardsSentenceStart(
                    convert("abc. a|bc")), 
                convert("abc. |bc"))
        })

        it("cursor between sentences, delete middle", function() {
            
            assert.deepEqual(deleteBackwardsTowardsSentenceStart(
                    convert("abc. abc.| abc")), 
                convert("abc. | abc"))
        })
    })
})
