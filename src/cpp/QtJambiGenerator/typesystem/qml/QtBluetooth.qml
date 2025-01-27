/****************************************************************************
**
** Copyright (C) 2009-2023 Dr. Peter Droste, Omix Visualization GmbH & Co. KG. All rights reserved.
**
** This file is part of QtJambi.
**
** $BEGIN_LICENSE$
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

import QtJambiGenerator 1.0

TypeSystem{
    packageName: "io.qt.bluetooth"
    defaultSuperClass: "io.qt.QtObject"
    qtLibrary: "QtBluetooth"
    module: "qtjambi.bluetooth"
    description: "Provides access to Bluetooth hardware."

    InjectCode{
        target: CodeClass.MetaInfo
        position: Position.Position1
        Text{content: "void initialize_meta_info_QtBluetooth();"}
    }
    
    InjectCode{
        target: CodeClass.MetaInfo
        Text{content: "initialize_meta_info_QtBluetooth();"}
    }
    
    RequiredLibrary{
        name: "QtConcurrent"
        mode: RequiredLibrary.Optional
        until: 5
    }
    
    Rejection{
        className: "QBluetoothSocketBasePrivate"
    }
    
    NamespaceType{
        name: "QBluetooth"
    }
    
    EnumType{
        name: "QBluetooth::AttAccessConstraint"
        flags: "QBluetooth::AttAccessConstraints"
    }
    
    EnumType{
        name: "QBluetooth::Security"
        flags: "QBluetooth::SecurityFlags"
    }
    
    EnumType{
        name: "QBluetoothDeviceDiscoveryAgent::DiscoveryMethod"
        flags: "QBluetoothDeviceDiscoveryAgent::DiscoveryMethods"
    }
    
    EnumType{
        name: "QBluetoothDeviceDiscoveryAgent::Error"
    }
    
    EnumType{
        name: "QBluetoothDeviceDiscoveryAgent::InquiryType"
    }
    
    EnumType{
        name: "QBluetoothServiceInfo::AttributeId"
        RejectEnumValue{
            name: "PrimaryLanguageBase"
        }
    }
    
    EnumType{
        name: "QBluetoothServiceInfo::Protocol"
    }
    
    EnumType{
        name: "QBluetoothSocket::SocketError"
    }
    
    EnumType{
        name: "QBluetoothSocket::SocketState"
    }
    
    EnumType{
        name: "QBluetoothDeviceInfo::CoreConfiguration"
        flags: "QBluetoothDeviceInfo::CoreConfigurations"
    }
    
    EnumType{
        name: "QBluetoothDeviceInfo::DataCompleteness"
    }
    
    EnumType{
        name: "QBluetoothDeviceInfo::Field"
        flags: "QBluetoothDeviceInfo::Fields"
    }
    
    EnumType{
        name: "QBluetoothDeviceInfo::MajorDeviceClass"
        RejectEnumValue{
            name: "NetworkDevice"
            until: 5
        }
    }
    
    EnumType{
        name: "QBluetoothDeviceInfo::MinorAudioVideoClass"
    }
    
    EnumType{
        name: "QBluetoothDeviceInfo::MinorComputerClass"
    }
    
    EnumType{
        name: "QBluetoothDeviceInfo::MinorHealthClass"
    }
    
    EnumType{
        name: "QBluetoothDeviceInfo::MinorImagingClass"
    }
    
    EnumType{
        name: "QBluetoothDeviceInfo::MinorMiscellaneousClass"
    }
    
    EnumType{
        name: "QBluetoothDeviceInfo::MinorNetworkClass"
    }
    
    EnumType{
        name: "QBluetoothDeviceInfo::MinorPeripheralClass"
    }
    
    EnumType{
        name: "QBluetoothDeviceInfo::MinorPhoneClass"
    }
    
    EnumType{
        name: "QBluetoothDeviceInfo::MinorToyClass"
    }
    
    EnumType{
        name: "QBluetoothDeviceInfo::MinorWearableClass"
    }
    
    EnumType{
        name: "QBluetoothDeviceInfo::ServiceClass"
        flags: "QBluetoothDeviceInfo::ServiceClasses"
    }
    
    EnumType{
        name: "QBluetoothLocalDevice::Error"
    }
    
    EnumType{
        name: "QBluetoothLocalDevice::HostMode"
    }
    
    EnumType{
        name: "QBluetoothLocalDevice::Pairing"
    }
    
    EnumType{
        name: "QBluetoothServer::Error"
    }
    
    EnumType{
        name: "QBluetoothServiceDiscoveryAgent::DiscoveryMode"
    }
    
    EnumType{
        name: "QBluetoothServiceDiscoveryAgent::Error"
    }
    
    EnumType{
        name: "QBluetoothTransferReply::TransferError"
        until: 5
    }
    
    EnumType{
        name: "QBluetoothTransferRequest::Attribute"
        until: 5
    }
    
    EnumType{
        name: "QBluetoothUuid::CharacteristicType"
    }
    
    EnumType{
        name: "QBluetoothUuid::DescriptorType"
    }
    
    EnumType{
        name: "QBluetoothUuid::ProtocolUuid"
    }
    
    EnumType{
        name: "QBluetoothUuid::ServiceClassUuid"
    }
    
    EnumType{
        name: "QLowEnergyAdvertisingData::Discoverability"
    }
    
    EnumType{
        name: "QLowEnergyAdvertisingParameters::FilterPolicy"
    }
    
    EnumType{
        name: "QLowEnergyAdvertisingParameters::Mode"
    }
    
    EnumType{
        name: "QLowEnergyController::ControllerState"
    }
    
    EnumType{
        name: "QLowEnergyController::Error"
    }
    
    EnumType{
        name: "QLowEnergyController::RemoteAddressType"
    }
    
    EnumType{
        name: "QLowEnergyController::Role"
    }
    
    EnumType{
        name: "QLowEnergyService::ServiceError"
    }
    
    EnumType{
        name: "QLowEnergyService::ServiceState"
        RejectEnumValue{
            name: "DiscoveryRequired"
            since: [6, 2]
        }
        RejectEnumValue{
            name: "DiscoveringService"
        }
        RejectEnumValue{
            name: "ServiceDiscovered"
            since: [6, 2]
        }
    }
    
    EnumType{
        name: "QLowEnergyService::WriteMode"
    }
    
    EnumType{
        name: "QLowEnergyService::DiscoveryMode"
        since: [6, 2]
    }
    
    EnumType{
        name: "QLowEnergyService::ServiceType"
        flags: "QLowEnergyService::ServiceTypes"
    }
    
    EnumType{
        name: "QLowEnergyServiceData::ServiceType"
    }
    
    EnumType{
        name: "QLowEnergyCharacteristic::PropertyType"
        flags: "QLowEnergyCharacteristic::PropertyTypes"
    }
    
    ValueType{
        name: "QLowEnergyAdvertisingParameters::AddressInfo"
    }
    
    ValueType{
        name: "QBluetoothServiceInfo::Sequence"
        ExtraIncludes{
            Include{
                fileName: "hashes.h"
                location: Include.Local
            }
        }
    }
    
    ValueType{
        name: "QBluetoothServiceInfo::Alternative"
        ExtraIncludes{
            Include{
                fileName: "hashes.h"
                location: Include.Local
            }
        }
    }
    
    ValueType{
        name: "QBluetoothAddress"
        ModifyFunction{
            signature: "operator=(QBluetoothAddress)"
            remove: RemoveFlag.All
        }
    }
    
    ValueType{
        name: "QBluetoothServiceInfo"
        ModifyFunction{
            signature: "operator=(QBluetoothServiceInfo)"
            remove: RemoveFlag.All
        }
    }
    
    ValueType{
        name: "QBluetoothDeviceInfo"
        ModifyFunction{
            signature: "operator=(QBluetoothDeviceInfo)"
            remove: RemoveFlag.All
        }
        ExtraIncludes{
            Include{
                fileName: "utils_p.h"
                location: Include.Local
            }
        }
        InjectCode{
            until: [5, 13]
            Text{content: "public final static class ServiceUuids implements Iterable<QBluetoothUuid>{\n"+
                          "    private ServiceUuids(java.util.List<QBluetoothUuid> serviceUuids, DataCompleteness completeness) {\n"+
                          "        super();\n"+
                          "        this.serviceUuids = serviceUuids;\n"+
                          "        this.completeness = completeness;\n"+
                          "    }\n"+
                          "\n"+
                          "    public final java.util.List<io.qt.bluetooth.QBluetoothUuid> serviceUuids;\n"+
                          "    public final DataCompleteness completeness;\n"+
                          "\n"+
                          "    @Override\n"+
                          "    public java.util.Iterator<QBluetoothUuid> iterator() {\n"+
                          "        return serviceUuids.iterator();\n"+
                          "    }\n"+
                          "}"}
        }
        ModifyFunction{
            signature: "serviceUuids(QBluetoothDeviceInfo::DataCompleteness *) const"
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QBluetoothDeviceInfo::DataCompleteness* %out = nullptr;"}
                }
            }
            since: [5, 14]
            until: 5
        }
        ModifyFunction{
            signature: "serviceUuids(QBluetoothDeviceInfo::DataCompleteness *) const"
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QBluetoothDeviceInfo::DataCompleteness completeness;\n"+
                                  "QBluetoothDeviceInfo::DataCompleteness* %out = &completeness;"}
                }
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "io.qt.bluetooth.QBluetoothDeviceInfo$ServiceUuids"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = Java::QtBluetooth::QBluetoothDeviceInfo$ServiceUuids::newInstance(%env, qtjambi_cast<jobject>(%env, %in), qtjambi_cast<jobject>(%env, completeness));"}
                }
            }
            until: [5, 13]
        }
    }
    
    ValueType{
        name: "QBluetoothHostInfo"
        ModifyFunction{
            signature: "operator=(QBluetoothHostInfo)"
            remove: RemoveFlag.All
        }
    }
    
    ValueType{
        name: "QBluetoothTransferRequest"
        ModifyFunction{
            signature: "operator=(QBluetoothTransferRequest)"
            remove: RemoveFlag.All
        }
        until: 5
    }
    
    ValueType{
        name: "QBluetoothUuid"
        ModifyFunction{
            signature: "operator=(QBluetoothUuid)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toUInt128() const"
            rename: "toBytes"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "byte[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "Int8PointerArray %inArray(%env, reinterpret_cast<qint8*>(%in.data), 16);\n"+
                                  "%out = %env->NewByteArray(16);\n"+
                                  "%env->SetByteArrayRegion(jbyteArray(%out), 0, 16, reinterpret_cast<jbyte *>(%in.data));"}
                }
            }
        }
        ModifyFunction{
            signature: "QBluetoothUuid(quint128)"
            InjectCode{
                Text{content: "if(uuid.length!=16)\n"+
                              "    throw new IllegalArgumentException(\"Uuid needs to be an array of length 16.\");"}
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "byte[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "quint128 %out;\n"+
                                  "%env->GetByteArrayRegion(jbyteArray(%in), 0, 16, reinterpret_cast<jbyte *>(%out.data));"}
                }
            }
        }
        ModifyFunction{
            signature: "toUInt16(bool*) const"
            rename: "toShort"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.Short"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = ok ? QtJambiAPI::toJavaShortObject(%env, %in) : nullptr;"}
                }
            }
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "bool ok(false);\n"+
                                  "bool* %out = &ok;"}
                }
            }
        }
        ModifyFunction{
            signature: "toUInt32(bool*) const"
            rename: "toInt"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.Integer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = ok ? QtJambiAPI::toJavaIntegerObject(%env, %in) : nullptr;"}
                }
            }
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "bool ok(false);\n"+
                                  "bool* %out = &ok;"}
                }
            }
        }
    }
    
    ObjectType{
        name: "quint128"
        generate: false
    }
    
    ValueType{
        name: "QLowEnergyAdvertisingData"
        ModifyFunction{
            signature: "operator=(QLowEnergyAdvertisingData)"
            remove: RemoveFlag.All
        }
    }
    
    ValueType{
        name: "QLowEnergyAdvertisingParameters"
        ModifyFunction{
            signature: "operator=(QLowEnergyAdvertisingParameters)"
            remove: RemoveFlag.All
        }
    }
    
    ValueType{
        name: "QLowEnergyDescriptor"
        ModifyFunction{
            signature: "operator=(QLowEnergyDescriptor)"
            remove: RemoveFlag.All
        }
    }
    
    ValueType{
        name: "QLowEnergyDescriptorData"
        ModifyFunction{
            signature: "operator=(QLowEnergyDescriptorData)"
            remove: RemoveFlag.All
        }
    }
    
    ValueType{
        name: "QLowEnergyCharacteristic"
        ModifyFunction{
            signature: "operator=(QLowEnergyCharacteristic)"
            remove: RemoveFlag.All
        }
    }
    
    ValueType{
        name: "QLowEnergyCharacteristicData"
        ModifyFunction{
            signature: "operator=(QLowEnergyCharacteristicData)"
            remove: RemoveFlag.All
        }
    }
    
    ValueType{
        name: "QLowEnergyConnectionParameters"
        ModifyFunction{
            signature: "operator=(QLowEnergyConnectionParameters)"
            remove: RemoveFlag.All
        }
    }
    
    ValueType{
        name: "QLowEnergyServiceData"
        ModifyFunction{
            signature: "operator=(QLowEnergyServiceData)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "setIncludedServices(const QList<QLowEnergyService*>&)"
            InjectCode{
                position: Position.End
                Text{content: "if(__rcIncludedService!=null){\n"+
                              "    __rcIncludedService.clear();\n"+
                              "}else{\n"+
                              "    __rcIncludedService = new java.util.ArrayList<>();\n"+
                              "}\n"+
                              "__rcIncludedService.addAll(services);"}
            }
        }
        ModifyFunction{
            signature: "addIncludedService(QLowEnergyService *)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcIncludedService"
                    action: ReferenceCount.Add
                }
            }
        }
    }
    
    ObjectType{
        name: "QBluetoothDeviceDiscoveryAgent"
    }
    
    ObjectType{
        name: "QBluetoothLocalDevice"
    }
    
    ObjectType{
        name: "QBluetoothSocket"
        ModifyFunction{
            signature: "errorString() const"
            rename: "socketErrorString"
        }
    }
    
    ObjectType{
        name: "QBluetoothServer"
    }
    
    ObjectType{
        name: "QBluetoothServiceDiscoveryAgent"
    }
    
    ObjectType{
        name: "QBluetoothTransferManager"
    }
    
    ObjectType{
        name: "QBluetoothTransferReply"
        ModifyFunction{
            signature: "setManager(QBluetoothTransferManager*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcManager"
                    action: ReferenceCount.Set
                }
            }
        }
        until: 5
    }
    
    ObjectType{
        name: "QLowEnergyController"
        ModifyFunction{
            signature: "addService(QLowEnergyServiceData,QObject*)"
            ModifyArgument{
                index: 2
                ReferenceCount{
                    action: ReferenceCount.Ignore
                }
            }
        }
        ModifyFunction{
            signature: "createPeripheral(QBluetoothAddress,QObject*)"
            ModifyArgument{
                index: 0
                DefineOwnership{
                    codeClass: CodeClass.Shell
                    ownership: Ownership.Cpp
                }
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Java
                }
            }
            since: [6, 2]
        }
        ExtraIncludes{
            Include{
                fileName: "QtJambi/JavaAPI"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "createServiceObject(const QBluetoothUuid &, QObject *)"
            ModifyArgument{
                index: "return"
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Java
                }
            }
        }
        ModifyFunction{
            signature: "createCentral(const QBluetoothDeviceInfo &, QObject *)"
            ModifyArgument{
                index: "return"
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Java
                }
            }
        }
        ModifyFunction{
            signature: "createCentral(const QBluetoothDeviceInfo &,QBluetoothAddress,QObject *)"
            ModifyArgument{
                index: "return"
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Java
                }
            }
            since: [6, 2]
        }
        ModifyFunction{
            signature: "createCentral(QBluetoothAddress,QBluetoothAddress,QObject*)"
            ModifyArgument{
                index: "return"
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Java
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "createPeripheral(QObject *)"
            ModifyArgument{
                index: "return"
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Java
                }
            }
        }
    }
    
    ObjectType{
        name: "QLowEnergyService"
    }
    
    SuppressedWarning{text: "WARNING(CppImplGenerator) :: Object type 'quint128' passed as value. Resulting code will not compile.  io.qt.bluetooth.QBluetoothUuid::QBluetoothUuid(quint128 uuid)"}
    SuppressedWarning{text: "WARNING(JavaGenerator) :: Either add or remove specified for reference count variable '__rcIncludedService' in 'QLowEnergyServiceData' but not both."}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched parameter type 'QSharedPointer<*Private>'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping field '*' with unmatched type '*Private'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QBluetooth::operator|', unmatched return type '*'"}
    SuppressedWarning{text: "WARNING(JavaGenerator) :: No ==/!= operator found for value type QBluetoothServiceInfo::*."}
}
