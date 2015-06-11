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

import dom4.Document;
import dom4.DOMParser;
import dom4.utils.BasicContentSink;
import dom4.utils.Serializer;

import utest.Assert;
import utest.Runner;
import utest.ui.Report;

class Test {
  public function new() {}

  static function main() : Void {
    var runner = new Runner();

    runner.addCase(new Test());
    Report.create(runner);
    runner.run();

    var str = "<!DOCTYPE foobar><foobar xmlns='http://example.org/example.org/example.org/example.org/example.org/example.org/' xmlns:html='http://www.w3.org/1999/xhtml'>  a&lt;éaaaa  <html:p>   foobar<span>blag</span>  sdsdsdf</html:p>  <myelem label='fo\"o'/></foobar>  ";

    var contentSink = new BasicContentSink();
    var parser      = new DOMParser(contentSink);
    try {
      var document = parser.parseFromString(str, "text/xml");

      Sys.println("-----------------------");
      Sys.println("Original XML string to parse:\n");
      Sys.println(str);
      Sys.println("-----------------------");
      Sys.println("Name of the document element is: " + document.documentElement.nodeName);
      Sys.println("Document element has " + document.documentElement.childNodes.length + " children");
      Sys.println("Document element has " + document.documentElement.children.length + " element children");

      Sys.println("-----------------------");
      Sys.println("Document serialization:\n");
      var s = new Serializer();
      s.enableIndentation();
      s.enableWrapping(72);
      Sys.println(s.serializeToString(document));
      Sys.println("-----------------------");
    }
    catch(e: String) {
      Sys.println("EXCEPTION CAUGHT: " + e);
    }
  }
}
