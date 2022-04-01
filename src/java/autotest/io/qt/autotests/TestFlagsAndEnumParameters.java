/****************************************************************************
**
** Copyright (C) 1992-2009 Nokia. All rights reserved.
** Copyright (C) 2009-2022 Dr. Peter Droste, Omix Visualization GmbH & Co. KG. All rights reserved.
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
package io.qt.autotests;

import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.lang.ref.WeakReference;
import java.util.List;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;

import io.qt.QFlags;
import io.qt.QtFlagEnumerator;
import io.qt.autotests.generated.EnumNamespace;
import io.qt.autotests.generated.FlagsAndEnumTest;
import io.qt.autotests.generated.GlobalEnumTest;
import io.qt.autotests.generated.TheExtensibleGlobalLongEnumClass;
import io.qt.autotests.generated.TheGlobalCharEnumStruct;
import io.qt.autotests.generated.TheGlobalEnum;
import io.qt.autotests.generated.TheGlobalEnumClass;
import io.qt.autotests.generated.TheGlobalFlag;
import io.qt.autotests.generated.TheGlobalFlags;
import io.qt.autotests.generated.TheGlobalIntegerEnum;
import io.qt.autotests.generated.TheGlobalLongEnumStruct;
import io.qt.autotests.generated.TheGlobalLongIntegerEnumClass;
import io.qt.autotests.generated.TheGlobalShortEnum;
import io.qt.autotests.generated.TheGlobalShortEnumClass;
import io.qt.core.QMetaMethod;
import io.qt.core.QMetaObject.Connection;
import io.qt.core.Qt;

public class TestFlagsAndEnumParameters extends FlagsAndEnumTest{
	
	public TestFlagsAndEnumParameters() {
		ApplicationInitializer.instances.add(new WeakReference<>(this));
	}
	
	@BeforeClass
    public static void testInitialize() throws Exception {
		ApplicationInitializer.testInitialize();
    }
	
	@AfterClass
    public static void testDispose() throws Exception {
		ApplicationInitializer.testDispose();
	}
	
    public static void main(String args[]) {
        org.junit.runner.JUnitCore.main(TestDestruction.class.getName());
    }
	
	public final Signal1<TestEnum> testSignal6 = new Signal1<TestEnum>();
	public final Signal1<TestEnum2> testSignal7 = new Signal1<TestEnum2>();
	public final Signal1<MyFlags> testSignal8 = new Signal1<MyFlags>();
	
	private io.qt.core.Qt.WidgetAttribute[] buffer;
	private final FlagsAndEnumTest flagsAndEnumTest = new FlagsAndEnumTest(){
		{
			ApplicationInitializer.instances.add(new WeakReference<>(this));
		}
	    @io.qt.QtPropertyWriter(enabled=false)
		public void setAttributes(io.qt.core.Qt.WidgetAttribute ... attributes){
			buffer = attributes;
			super.setAttributes(attributes);
		}
	};
	
	private int result;
	
	@Test
	public void testGlobalEnums(){
		assertEquals(TheGlobalEnum.Two, GlobalEnumTest.getGlobalEnum());
		assertEquals(TheGlobalShortEnum.Seven, GlobalEnumTest.getGlobalShortEnum());
		assertEquals(TheGlobalFlag.Flag3, GlobalEnumTest.getGlobalFlag());
		assertEquals(new TheGlobalFlags(TheGlobalFlag.Flag2, TheGlobalFlag.Flag3), GlobalEnumTest.getGlobalFlags());
		assertEquals(TheGlobalIntegerEnum.B, GlobalEnumTest.getGlobalIntegerEnum());
		assertEquals(TheGlobalShortEnumClass.Entry3, GlobalEnumTest.getGlobalShortEnumClass());
		assertEquals(TheGlobalCharEnumStruct.Entry2, GlobalEnumTest.getGlobalCharEnumStruct());
		assertEquals(TheGlobalLongEnumStruct.Entry2, GlobalEnumTest.getGlobalLongEnumStruct());
		assertEquals(TheExtensibleGlobalLongEnumClass.Entry3, GlobalEnumTest.getExtensibleGlobalLongEnumClass());
		assertEquals(TheGlobalLongIntegerEnumClass.Entry3, GlobalEnumTest.getGlobalLongIntegerEnumClass());
		assertEquals(9900000000000L, GlobalEnumTest.getExtendedExtensibleGlobalLongEnumClass().value());
		assertEquals(TheGlobalEnumClass.Entry2, GlobalEnumTest.getGlobalEnumClass());
		assertEquals(EnumNamespace.NSFlag.Flag2, GlobalEnumTest.getNSFlag());
		assertEquals(new EnumNamespace.NSFlags(EnumNamespace.NSFlag.Flag2, EnumNamespace.NSFlag.Flag4), GlobalEnumTest.getNSFlags());
		assertEquals(EnumNamespace.NSEnumClass.Entry4, GlobalEnumTest.getNSEnumClass());
		assertEquals(EnumNamespace.NSClassFlag.Flag2, GlobalEnumTest.getNSClassFlag());
		assertEquals(new EnumNamespace.NSClassFlags(EnumNamespace.NSClassFlag.Flag2, EnumNamespace.NSClassFlag.Flag1, EnumNamespace.NSClassFlag.Flag3), GlobalEnumTest.getNSClassFlags());
		assertTrue(GlobalEnumTest.testGlobalEnum());
		assertTrue(GlobalEnumTest.testGlobalShortEnum());
		assertTrue(GlobalEnumTest.testGlobalFlag());
		assertTrue(GlobalEnumTest.testGlobalFlags());
		assertTrue(GlobalEnumTest.testGlobalIntegerEnum());
		assertTrue(GlobalEnumTest.testGlobalEnumClass());
		assertTrue(GlobalEnumTest.testGlobalCharEnumStruct());
		assertTrue(GlobalEnumTest.testGlobalLongEnumStruct());
		assertTrue(GlobalEnumTest.testGlobalShortEnumClass());
		assertTrue(GlobalEnumTest.testGlobalLongIntegerEnumClass());
		assertTrue(GlobalEnumTest.testExtensibleGlobalLongEnumClass());
		assertTrue(GlobalEnumTest.testNSFlag());
		assertTrue(GlobalEnumTest.testNSFlags());
		assertTrue(GlobalEnumTest.testNSEnumClass());
		assertTrue(GlobalEnumTest.testNSClassFlag());
		assertTrue(GlobalEnumTest.testNSClassFlags());
	}
	
	@Test
	public void testEmitNativeSignal1() throws Throwable{
		try{
			result = 0;
			QMetaMethod method = this.metaObject().method("testSignal1", Qt.AlignmentFlag.class);
			assertTrue(method!=null);
			method.invoke(this, Qt.AlignmentFlag.AlignJustify);
			assertEquals(Qt.AlignmentFlag.AlignJustify, Qt.AlignmentFlag.resolve(result));
		}catch(io.qt.QNoSuchEnumValueException e){
			org.junit.Assert.fail("No Such Enum Value: Qt.AlignmentFlag " + result+"\n"+e.getMessage());
		}
	}
	
	@Test
	public void testEmitSignal1() throws Throwable{
		try{
			result = 0;
			testSignal1.emit(Qt.AlignmentFlag.AlignJustify);
			assertEquals(Qt.AlignmentFlag.AlignJustify, Qt.AlignmentFlag.resolve(result));
		}catch(io.qt.QNoSuchEnumValueException e){
			org.junit.Assert.fail("No Such Enum Value: Qt.AlignmentFlag " + result+"\n"+e.getMessage());
		}
	}
	
	@Test
	public void testEmitNativeSignal2() throws Throwable{
		try{			
			result = 0;
			QMetaMethod method = this.metaObject().method("testSignal2", Qt.Orientation.class);
			assertTrue(method!=null);
			method.invoke(this, Qt.Orientation.Horizontal);
			assertEquals(Qt.Orientation.Horizontal, Qt.Orientation.resolve(result));
		}catch(io.qt.QNoSuchEnumValueException e){
			org.junit.Assert.fail("No Such Enum Value: Qt.AlignmentFlag " + result+"\n"+e.getMessage());
		}
	}
	
	@Test
	public void testEmitSignal2() throws Throwable{
		try{			
			result = 0;
			testSignal2.emit(Qt.Orientation.Horizontal);
			assertEquals(Qt.Orientation.Horizontal, Qt.Orientation.resolve(result));
		}catch(io.qt.QNoSuchEnumValueException e){
			org.junit.Assert.fail("No Such Enum Value: Qt.AlignmentFlag " + result+"\n"+e.getMessage());
		}
	}
	
	@Test
	public void testEmitNativeSignal3() throws Throwable{
		result = 0;
		QMetaMethod method = this.metaObject().method("testSignal3", Qt.Alignment.class);
		assertTrue(method!=null);
		Qt.Alignment a = new Qt.Alignment(Qt.AlignmentFlag.AlignTop, Qt.AlignmentFlag.AlignJustify);
		method.invoke(this, a);
		assertEquals(a, new Qt.Alignment(result));
	}
	
	@Test
	public void testEmitSignal3() throws Throwable{
		result = 0;
		Qt.Alignment a = new Qt.Alignment(Qt.AlignmentFlag.AlignTop, Qt.AlignmentFlag.AlignJustify);
		testSignal3.emit(a);
		assertEquals(a, new Qt.Alignment(result));
	}
	
	@Test
	public void testCustomEnumSignals() throws Throwable{
		// must not crash internally inside MetaObjectTools.emitNativeSignal()
		testSignal6.emit(TestEnum.ENTRY1);
		testSignal7.emit(TestEnum2.ENTRY2);
		testSignal8.emit(new MyFlags(TestEnum2.ENTRY3, TestEnum2.ENTRY2));
	}
	
	@Test
	public void testInitializerList1(){
		Qt.WidgetAttribute[] attributes = {
			Qt.WidgetAttribute.WA_TranslucentBackground,
			Qt.WidgetAttribute.WA_X11NetWmWindowTypeDesktop,
			Qt.WidgetAttribute.WA_OpaquePaintEvent
		};
		result = 0;
		Qt.WidgetAttribute[][] receivedAttributes = {null};
		Connection connection = testSignal4.connect(attr->{
			receivedAttributes[0] = attr;
		});
		assertTrue(connection!=null);
		testSignal4.emit(attributes);
		assertEquals("testSignal4 result",
						Qt.WidgetAttribute.WA_TranslucentBackground.value() +
						Qt.WidgetAttribute.WA_X11NetWmWindowTypeDesktop.value() +
						Qt.WidgetAttribute.WA_OpaquePaintEvent.value(), result);
		result = 0;
		assertArrayEquals("getAttributes() after emmitting testSignal4", attributes, getAttributes().toArray(new Qt.WidgetAttribute[3]));
		assertArrayEquals("receivedAttributes after emmitting testSignal4", attributes, receivedAttributes[0]);
	}
	
	@Test
	public void testInitializerList3(){
		this.setAttributes(Qt.WidgetAttribute.WA_DeleteOnClose, Qt.WidgetAttribute.WA_PaintOnScreen);
		assertArrayEquals("getAttributes() after setAttributes(...)", new Qt.WidgetAttribute[]{Qt.WidgetAttribute.WA_DeleteOnClose, Qt.WidgetAttribute.WA_PaintOnScreen}, getAttributes().toArray(new Qt.WidgetAttribute[2]));
	}
	
	@Test
	public void testInitializerList4(){
		Qt.WidgetAttribute[] attributes = {
			Qt.WidgetAttribute.WA_CustomWhatsThis,
			Qt.WidgetAttribute.WA_DontShowOnScreen,
			Qt.WidgetAttribute.WA_KeyboardFocusChange
		};
		buffer = null;
		flagsAndEnumTest.testSignal4.emit(attributes);
		assertArrayEquals("buffer after emmitting testSignal4 in overriding class", attributes, buffer);
		assertArrayEquals("getAttributes() after emmitting testSignal4 in overriding class", attributes, flagsAndEnumTest.getAttributes().toArray(new Qt.WidgetAttribute[3]));
	}
	
	@Test
	public void testInitializerList5(){
		Qt.WidgetAttribute[] attributes = {
			Qt.WidgetAttribute.WA_CustomWhatsThis,
			Qt.WidgetAttribute.WA_DontShowOnScreen,
			Qt.WidgetAttribute.WA_OpaquePaintEvent,
			Qt.WidgetAttribute.WA_TransparentForMouseEvents
		};
		buffer = null;
		flagsAndEnumTest.setAttributes(attributes);
		assertArrayEquals("buffer after setAttributes(...) in overriding class", attributes, buffer);
		assertArrayEquals("getAttributes() after setAttributes(...) in overriding class", attributes, flagsAndEnumTest.getAttributes().toArray(new Qt.WidgetAttribute[3]));
	}
	
	@Test
	public void testIntInitializerList1(){
		int[] numbers = {
			9752,3971,657941,3
		};
		result = 0;
		int[][] receivedNumbers = {null};
		Connection connection = testSignal5.connect(n->{
			receivedNumbers[0] = n;
		});
		assertTrue(connection!=null);
		testSignal5.emit(numbers);
		int sum = 0;
		for (int i = 0; i < numbers.length; i++) {
			sum += numbers[i];
		}
		assertEquals("testSignal5 result", sum, result);
		result = 0;
		List<Integer> ints = getInts();
		int[] _ints = new int[ints.size()];
		for (int i = 0; i < _ints.length; i++) {
			_ints[i] = ints.get(i);
		}
		assertArrayEquals("getInts() after emmitting testSignal5", numbers, _ints);
		assertArrayEquals("receivedNumbers after emmitting testSignal5", numbers, receivedNumbers[0]);
	}
	
	public enum AutoFlag implements QtFlagEnumerator{
		A,B,C,D,E,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Z,
		A1,B1,C1,D1,E1,G1,H1,I1,J1
	}
	
	private static class AutoFlags extends QFlags<AutoFlag>{
		private static final long serialVersionUID = 1297668415339650986L;
	}
	
	@Test
	public void testAutoFlag(){
		assertEquals(0x0200000, AutoFlag.X.value());
		assertEquals(0x02000, AutoFlag.P.value());
		assertEquals(AutoFlags.class, AutoFlag.P.asFlags().getClass());
	}
	
	public void processResult(int result) {
		this.result = result;
	}
	
	public enum TestEnum{
		ENTRY1, ENTRY2, ENTRY3
	}
	
	public enum TestEnum2 implements QtFlagEnumerator{
		ENTRY1, ENTRY2, ENTRY3;

		@Override
		public int value() {
			return ordinal();
		}
		
		public static TestEnum2 resolve(int i){
			return TestEnum2.values()[i];
		}

		@Override
		public MyFlags asFlags() {
			return new MyFlags(value());
		}
	}
	
	public static class MyFlags extends QFlags<TestEnum2>{

		private static final long serialVersionUID = 5669819378912505068L;

		public MyFlags(TestEnum2... args) {
			super(args);
		}

		public MyFlags(int value) {
			super(value);
		}

		@Override
		public MyFlags clone() {
			return new MyFlags(value());
		}

		@Override
		public MyFlags combined(TestEnum2 flag) {
			return new MyFlags(value() | flag.value());
		}

		@Override
		public TestEnum2[] flags() {
			return flags(TestEnum2.values());
		}
		
	}
}
