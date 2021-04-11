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

package io.qt.dbus;

import io.qt.core.QVariant;

public class QDBusPendingReply3<A,B,C> extends QDBusPendingReply2<A,B> {

	private final Class<C> typeC;
	
	public QDBusPendingReply3() {
		typeC = null;
	}

	public QDBusPendingReply3(QDBusMessage message, Class<A> typeA, Class<B> typeB, Class<C> typeC) {
		super(message, typeA, typeB);
		this.typeC = typeC;
	}

	public QDBusPendingReply3(QDBusPendingCall call, Class<A> typeA, Class<B> typeB, Class<C> typeC) {
		super(call, typeA, typeB);
		this.typeC = typeC;
	}

	public QDBusPendingReply3(QDBusPendingReply3<A,B,C> other) {
		super(other);
		this.typeC = other.typeC;
	}

	@Override
	public QDBusPendingReply3<A,B,C> clone() {
		return new QDBusPendingReply3<A,B,C>(this);
	}

	@Override
	boolean isInvalid() {
		return super.isInvalid() || typeC==null;
	}

	@Override
	int numberOfArguments() {
		return super.numberOfArguments()+1;
	}

	@io.qt.QtUninvokable
	public final C argumentAt2(){
		return QVariant.convert(argumentAt(2), typeC);
	}
}
