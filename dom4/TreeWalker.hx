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

import dom4.NodeFilter;

enum TreeWalkerType {
  TREE_WALKER_FIRST;
  TREE_WALKER_LAST;
  TREE_WALKER_NEXT;
  TREE_WALKER_PREVIOUS;
}
/*
 * https://dom.spec.whatwg.org/#treewalker
 */

class TreeWalker {

  public var root(default, null): Node;

  public var whatToShow(default, null): FlagsWithAllState<WhatToShowFlag>;

  public var filter(default, null): NodeFilter;

  public var currentNode(default, default): Node;

  /*
   * https://dom.spec.whatwg.org/#dom-treewalker-parentnode
   */
  public function parentNode(): Node {
    // STEP 1
    var node = this.currentNode;
    // STEP 2
    while (node != null && node != this.root) {
      // STEP 2.1
      node = node.parentNode;
      // STEP 2.2
      if (node != null && NodeIterator._filterNode(node, whatToShow, filter) == FILTER_ACCEPT) {
        this.currentNode = node;
        return node;
      }
    }
    // STEP 3
    return null;
  }

  /**********************************************
   * HELPERS DEFINED BY SPECIFICATION
   **********************************************/

  public function new(root: Node, whatToShow: FlagsWithAllState<WhatToShowFlag>, filter: NodeFilter)
  {
    this.root = root;
    this.currentNode = root;
    this.whatToShow = whatToShow;
    this.filter = filter;
  }
}
