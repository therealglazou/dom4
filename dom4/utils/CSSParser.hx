/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is JSCSSP code.
 *
 * The Initial Developer of the Original Code is
* Disruptive Innovations SAS
 * Portions created by the Initial Developer are Copyright (C) 2010
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Daniel Glazman <d.glazman@partner.samsung.com>
 *
 * Alternatively, the contents of this file may be used under the terms of
 * either of the GNU General Public License Version 2 or later (the "GPL"),
 * or the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of this file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of this file under the terms of the MPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the MPL, the GPL or the LGPL.
 *
 * ***** END LICENSE BLOCK ***** */
 
package dom4.utils;

typedef SelectorSpecificity = {
    var a : UInt;
    var b : UInt;
    var c : UInt;
    var d : UInt;
}

class CSSParser  {

    /*
     * general purpose
     */
    private var mPreservedTokens : Array<Token>;
    private var mError : String;

    /*
     * for tokenization
     */
    private var mScanner : Scanner;
    private var mToken : Token;
    private var mLookAhead : Token;

    /*
     * TOKENIZATION
     */

    public function currentToken() : Token {
        return mToken;
    }

    public function getToken(aSkipWS : Bool, aSkipComment : Bool) : Token {
        if (null != mLookAhead) {
            mToken = mLookAhead;
            mLookAhead = null;
            return mToken;
        }

        mToken = mScanner.nextToken();
        while (null != mToken
               && ((aSkipWS && mToken.isWhiteSpace())
                   || (aSkipComment && mToken.isComment())))
            mToken = mScanner.nextToken();

        return mToken;
    }

    public function ungetToken() : Void {
        mLookAhead = mToken;
    }

    public function lookAhead(aSkipWS : Bool, aSkipComment : Bool) : Token {
        var preservedToken = mToken;
        mScanner.preserveState();
        var token = getToken(aSkipWS, aSkipComment);
        mScanner.restoreState();
        mToken = preservedToken;

        return token;
    }

    public function preserveState() {
        this.mPreservedTokens.push(this.currentToken());
        this.mScanner.preserveState();
    }

    public function restoreState() {
        if (0 != this.mPreservedTokens.length) {
            this.mScanner.restoreState();
            this.mToken = this.mPreservedTokens.pop();
        }
    }

    public function forgetState() {
        if (0 != this.mPreservedTokens.length) {
            this.mScanner.forgetState();
            this.mPreservedTokens.pop();
        }
    }

    public function getHexValue() : Token {
        this.mToken = this.mScanner.nextHexValue();
        return this.mToken;
    }

    public function new() {
        this.mPreservedTokens = [];
        this.mError = null;
    }

    public function isTokenCombinator(aToken : Token) : Bool {
        return (aToken.isWhiteSpace()
               || aToken.isSymbol("+")
               || aToken.isSymbol("~")
               || aToken.isSymbol(">"));
    }

    public function parseSelector(aString: DOMString): CSSSelector
    {
      var selector:CSSSelector = null;
      var newInGroup = true;
      var firstInChain = true;

      // init the scanner with our string to parse
      mScanner = new Scanner(aString);
      // let's dance, baby...
      var token = this.getToken(true, true);

      while (token.isNotNull()) {

        if (token.isSymbol(",")) { // group of selectors;
          // we need a new selector in the chain but we can't allow
          // two consecutive commas
          if (newInGroup)
            throw (new DOMException("SyntaxError"));
          newInGroup = true;
          // don't watch whitespaces after a comma
          token = this.getToken(true, true);
          continue;
        }

        if (selector != null
            && selector.pseudoElement != "") {
          // we just set a pseudo-element so we can
          // only end or have a comma
          var t = token;
          if (t.isWhiteSpace())
            t = this.lookAhead(true, true);
          if (t.isNotNull() && !t.isSymbol(","))
            throw (new DOMException("SyntaxError"));
        }

        // did we just find a comma?
        if (newInGroup) {
          // cannot have a combinator as first thing in a group
          if (this.isTokenCombinator(token))
            throw (new DOMException("SyntaxError"));

          newInGroup = false;
          firstInChain = true;
          var s = new CSSSelector();
          s.next = selector;
          selector = s;
        }

        // is it a combinator?
        if (token.isWhiteSpace()) {
          var nextToken = this.lookAhead(true, true);
          if (!token.isSymbol(",") && !this.isTokenCombinator(nextToken)) {
            // yes, it's a combinator
            var s = new CSSSelector();
            s.parent = selector;
            selector = s;
            selector.combinator = COMBINATOR_DESCENDANT;

            firstInChain = true;
            token = this.getToken(true, true);
            continue;
          }
        }
        // other combinators
        if (this.isTokenCombinator(token)) {
          var s = new CSSSelector();
          s.parent = selector;
          selector = s;
          if (token.isSymbol("+"))
            selector.combinator = COMBINATOR_ADJACENT_SIBLING;
          else if (token.isSymbol("~"))
            selector.combinator = COMBINATOR_SIBLING;
          else if (token.isSymbol(">"))
            selector.combinator = COMBINATOR_CHILD;

          firstInChain = true;
          token = this.getToken(true, true);
          continue;
        }

        // TYPE ELEMENT SELECTOR
        if (firstInChain
            && (token.isSymbol("*")
                || token.isIdent())) {
          // this is a type element selector
          selector.elementType = token.value;
        }

        // ID SELECTOR
        else if (token.isSymbol("#")) {
          token = this.getToken(false, true);
          if (!token.isNotNull() || !token.isIdent())
            throw (new DOMException("SyntaxError"));
          selector.IDList.push(token.value);
        }

        // CLASS SELECTOR
        else if (token.isSymbol(".")) {
          token = this.getToken(false, true);
          if (!token.isNotNull() || !token.isIdent())
            throw (new DOMException("SyntaxError"));
          selector.ClassList.push(token.value);
        }

        // PSEUDO CLASS AND ELEMENT
        else if (token.isSymbol(":")) {
          token = this.getToken(false, true);
          if (!token.isNotNull())
            throw (new DOMException("SyntaxError"));
          // is it a double-colon for a pseudo-element?
          if (token.isSymbol(":")) {
            token = this.getToken(false, true);
            if (!token.isNotNull() || !token.isIdent())
              throw (new DOMException("SyntaxError"));
            if (!CSSSelector.isPseudoElement(token.value))
              throw (new DOMException("SyntaxError"));
            selector.pseudoElement = token.value;
          }
          else if (token.isIdent()) {
            // no, it's supposed to be a pseudo-class or a single-
            // colon pseudo-element
            if (CSSSelector.isPseudoElement(token.value))
              selector.pseudoElement = token.value;
            else if (CSSSelector.isPseudoClass(token.value)) {
              selector.PseudoClassList.push(token.value);
            }
            else // unknown...
              throw (new DOMException("SyntaxError"));
          }
          else if (token.isFunction()
                   && CSSSelector.isFunctionalPseudoClass(token.value)) {
            if (token.value == "lang(") {
              var langArray: Array<DOMString> = [];
              token = this.getToken(true, true);
              var expectingString = true;
              while (token.isNotNull()) {
                if (token.isSymbol(")")) {
                  if (expectingString)
                    throw (new DOMException("SyntaxError"));
                  break;
                }
                else if (token.isSymbol(",") && !expectingString) {
                  expectingString = true;
                }
                else if (token.isIdent() && expectingString) {
                  langArray.push(token.value);
                  expectingString = false;
                }
                else if (token.isSymbol("*") && !expectingString) {
                  token = this.getToken(false, true);
                  if (!token.isIdent())
                    throw (new DOMException("SyntaxError"));
                  langArray.push("*" + token.value);
                  expectingString = false;
                }
                else
                  throw (new DOMException("SyntaxError"));

                token = this.getToken(true, true);
              }
              selector.LangPseudoClassList.push(langArray);
            }
            else {
              // that's a nth-*() function
              // TBD
            }
          }
          else // not a known pseudo-class
            throw (new DOMException("SyntaxError"));
        }

        // ATTR SELECTORS
        if (token.isSymbol("[")) {
          
        }

        else
          throw (new DOMException("SyntaxError"));

        token = this.getToken(false, true);
        firstInChain = false;
      } // END while (token.isNotNull())

      if (newInGroup) // hey we started a new group but received nothing
        throw (new DOMException("SyntaxError"));

      return selector;
    }
}
