#!/bin/bash
# Switches macOS audio output to a named device using CoreAudio via inline Swift.
# Usage: ./switch-audio.sh ["Device Name"]

DEVICE_NAME="${1:-MacBook Pro Speakers}"

swift - "$DEVICE_NAME" <<'SWIFT'
import CoreAudio
import Foundation

let name = CommandLine.arguments[1]

var size: UInt32 = 0
var addr = AudioObjectPropertyAddress(
    mSelector: kAudioHardwarePropertyDevices,
    mScope: kAudioObjectPropertyScopeGlobal,
    mElement: kAudioObjectPropertyElementMain
)

AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &addr, 0, nil, &size)
let count = Int(size) / MemoryLayout<AudioDeviceID>.size
var devices = [AudioDeviceID](repeating: 0, count: count)
AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &addr, 0, nil, &size, &devices)

for id in devices {
    var cfName: CFString? = nil
    var nameSize = UInt32(MemoryLayout<CFString?>.size)
    var nameAddr = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyDeviceNameCFString,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    AudioObjectGetPropertyData(id, &nameAddr, 0, nil, &nameSize, &cfName)

    guard let deviceName = cfName as String?, deviceName == name else { continue }

    // Check it's an output device
    var streamSize: UInt32 = 0
    var streamAddr = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyStreams,
        mScope: kAudioDevicePropertyScopeOutput,
        mElement: kAudioObjectPropertyElementMain
    )
    AudioObjectGetPropertyDataSize(id, &streamAddr, 0, nil, &streamSize)
    guard streamSize > 0 else { continue }

    // Set as default output
    var devId = id
    let propSize = UInt32(MemoryLayout<AudioDeviceID>.size)
    var outAddr = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultOutputDevice,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    let status = AudioObjectSetPropertyData(AudioObjectID(kAudioObjectSystemObject), &outAddr, 0, nil, propSize, &devId)
    if status == noErr {
        print("Audio output set to \"\(deviceName)\"")
    } else {
        print("Failed to set audio output (error \(status))")
        exit(1)
    }
    exit(0)
}

print("Device \"\(name)\" not found")
exit(1)
SWIFT
