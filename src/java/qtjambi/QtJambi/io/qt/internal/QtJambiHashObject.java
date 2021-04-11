/****************************************************************************
**
** Copyright (C) 2009-2021 Dr. Peter Droste, Omix Visualization GmbH & Co. KG. All rights reserved.
**
** This file is part of Qt Jambi.
**
** ** $BEGIN_LICENSE$
** GNU Lesser General Public License Usage
** This file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
** 
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3.0 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU General Public License version 3.0 requirements will be
** met: http://www.gnu.org/copyleft/gpl.html.
** $END_LICENSE$

**
** This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
** WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
**
****************************************************************************/
package io.qt.internal;

import java.util.AbstractMap;
import java.util.HashSet;
import java.util.Set;

import io.qt.QtUninvokable;
import io.qt.core.QPair;

public abstract class QtJambiHashObject<K, V> extends QtJambiAbstractMapObject<K, V> {

	protected QtJambiHashObject() {
		super();
	}

	protected QtJambiHashObject(QPrivateConstructor p) {
		super(p);
	}
	
	@Override
    @QtUninvokable
	public final Set<K> keySet() {
		return new HashSet<>(keys());
	}
	
	@Override
    @QtUninvokable
	public final Set<Entry<K, V>> entrySet() {
		Set<Entry<K, V>> entrySet = new HashSet<>();
		for(QPair<K,V> pair : this) {
			entrySet.add(new AbstractMap.SimpleImmutableEntry<>(pair.first, pair.second));
		}
		return entrySet;
	}
}
