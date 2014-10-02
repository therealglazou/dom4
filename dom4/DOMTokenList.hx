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
 * The Original Code is dom4 code.
 *
 * The Initial Developer of the Original Code is
 * Disruptive Innovations SAS
 * Portions created by the Initial Developer are Copyright (C) 2014
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Daniel Glazman <daniel.glazman@disruptive-innovations.com>
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


package dom4;

class DOMTokenList {

  /*
   * https://dom.spec.whatwg.org/#interface-domtokenlist
   */

  static private inline var SPACE_MATCHING = "[\u0009\u000a\u000c\u000d\u0020]";
  static public         var SPACE_MATCHING_EREG  = new EReg(SPACE_MATCHING, "g");
  
  private var stringArray: Array<String>;

  /*
   * https://dom.spec.whatwg.org/#dom-domtokenlist-length
   */
  public var length(get, null): UInt;
      private function get_length(): UInt
      {
        return stringArray.length;
      }

  /*
   * https://dom.spec.whatwg.org/#dom-domtokenlist-item
   */
  public function item(index: UInt): DOMString
  {
    return (index >= this.length) ? null : this.stringArray[index];
  }

  /*
   * https://dom.spec.whatwg.org/#dom-domtokenlist-contains
   */
  public function contains(token: DOMString): Bool
  {
    if (token == "")
      throw "Syntax error";
    if (SPACE_MATCHING_EREG.match(token))
      throw "Invalid character error";
    return (-1 != this.stringArray.indexOf(token));
  }

  /*
   * https://dom.spec.whatwg.org/#dom-domtokenlist-add
   */
  private function add(tokens: StringOrArrayString): Void
  {
    var a:Array<String> = tokens; 
    for (token in a) {
      if (token == "")
        throw "Syntax error";
      if (SPACE_MATCHING_EREG.match(token))
        throw "Invalid character error";
      if (!this.contains(token))
        this.stringArray.push(token);
    }
  }

  /*
   * https://dom.spec.whatwg.org/#dom-domtokenlist-stringifier
   */
  public function toString(): DOMString
  {
    return this.stringArray.join(" ");
  }

  /*
   * https://dom.spec.whatwg.org/#dom-domtokenlist-remove
   */
  public function remove(tokens: StringOrArrayString): Void
  {
    var a:Array<String> = tokens; 
    for (token in a) {
      if (token == "")
        throw "Syntax error";
      if (SPACE_MATCHING_EREG.match(token))
        throw "Invalid character error";
      this.stringArray = this.stringArray.filter(function(f) {
        return (f != token);
      });
    }
  }

  /*
   * https://dom.spec.whatwg.org/#dom-domtokenlist-toggle
   */
  public function toggle(token: DOMString, ?force: Bool)
  {
    if (this.contains(token)) {
      if (force == null || !force) {
        this.stringArray = this.stringArray.filter(function(f) {
          return (f != token);
        });
        return false;
      }
      return true;
    }

    if (force != null && !force)
      return false;

    this.stringArray.push(token);
    return true;
  }

  public function new(v:DOMString)
  {
    this.stringArray = StringTools.trim(DOMTokenList.SPACE_MATCHING_EREG.replace(v, " ")).split(" ");
  }
}

abstract StringOrArrayString(Array<DOMString>) from Array<DOMString> to Array<DOMString> {
    @:from
    static function fromString(s:DOMString) {
        return [s];
    }
}