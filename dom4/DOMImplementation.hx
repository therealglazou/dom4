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

/*
 * http://www.w3.org/TR/domcore/#interface-domimplementation
 */
class DOMImplementation {

  static private inline var NAME_START_CHAR = "A-Z_a-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF\u0370-\u037D\u037F-\u1FFF\u200C-\u200D\u2070-\u218F\u2C00-\u2FEF\u3001-\uD7FF\uF900-\uFDCF\uFDF0-\uFFFD";
  static private inline var NAME_CHAR = NAME_START_CHAR + "\\-\\.0-9\u00B7\u0300-\u036F\u203F-\u2040";
  static public  inline var NAME = "^[" + NAME_START_CHAR + "][" + NAME_CHAR + "]*$";

  public function new() {
  }

  static public function createDocument(namespace: DOMString, qualifiedName: DOMString, ?doctype: DocumentType = null) : Document
  {
    var doc = new Document();
    var e = null;
    if (qualifiedName != "")
      e = doc.createElementNS(namespace, qualifiedName);
    if (doctype != null)
      cast(doc, Node).appendChild(cast(doctype, Node));
    if (e != null)
      cast(doc, Node).appendChild(cast(e, Node));

    return doc;
  }

  static public function createDocumentType(qualifiedName: DOMString, publicId: DOMString, systemId: DOMString): Dynamic
  {
    return 1;
  }
}
