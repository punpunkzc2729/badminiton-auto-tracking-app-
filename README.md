# Badminton Auto-Tracking System

ระบบติดตามและนับคะแนนแบดมินตันอัตโนมัติด้วย AI/ML สำหรับ iOS, iPadOS และ macOS

## ภาพรวมระบบ

โปรเจคนี้ประกอบด้วย 3 ส่วนหลัก:

1. **BadmintonCore** - Swift Package สำหรับ shared logic
2. **BadmintonCamera** - iOS app สำหรับ iPhone (กล้องจับภาพ)
3. **BadmintonTracker** - Multi-platform app สำหรับ iPad/Mac (ประมวลผล ML และนับคะแนน)

## สถาปัตยกรรม

```
iPhone (Camera App)
       ↓ Video Stream
iPad/Mac (Tracker App)
       ↓ ML Processing
    Score Update
```

### การทำงาน

1. **iPhone** ใช้กล้องจับภาพการเล่นแบดมินตัน และส่ง video stream ไปยัง iPad/Mac
2. **iPad/Mac** ใช้ Vision Framework และ Core ML ตรวจจับผู้เล่น, ลูกขนไก่, และวิเคราะห์การจบของแต่ละ rally
3. ระบบนับคะแนนอัตโนมัติตามกฎแบดมินตัน
4. อุปกรณ์ทั้งสองเชื่อมต่อกันผ่าน **Multipeer Connectivity** (peer-to-peer)

## ฟีเจอร์หลัก

- ✅ นับคะแนนอัตโนมัติตามกฎแบดมินตัน (21 คะแนน, deuce, best of 3/5)
- 🎥 Video streaming แบบ real-time จาก iPhone ไป iPad/Mac
- 🤖 ตรวจจับผู้เล่นและลูกขนไก่ด้วย on-device ML (Vision Framework + Core ML)
- 🔄 ระบบ Undo/Redo
- 📊 แสดงผลคะแนนแบบ real-time
- 🎯 Manual override สำหรับแก้ไขคะแนน
- 📱 รองรับ iOS 16+, iPadOS 16+, macOS 13+

## โครงสร้างโปรเจค

```
badminton/
├── BadmintonCore/              # Swift Package (Shared code)
│   ├── Package.swift
│   ├── Sources/
│   │   └── BadmintonCore/
│   │       ├── Models.swift              # Data models
│   │       ├── ScoringEngine.swift       # Badminton scoring logic
│   │       ├── NetworkProtocol.swift     # Message protocol
│   │       └── MultipeerService.swift    # P2P communication
│   └── Tests/
│       └── BadmintonCoreTests/
│           └── ScoringEngineTests.swift  # Unit tests
│
├── BadmintonCamera/            # iPhone Camera App
│   └── (Coming next...)
│
└── BadmintonTracker/           # iPad/Mac Processing App
    └── (Coming next...)
```

## เทคโนโลยีที่ใช้

| Component | Technology |
|-----------|------------|
| **UI** | SwiftUI |
| **Architecture** | MVVM |
| **Concurrency** | Swift Concurrency (async/await) |
| **Camera** | AVFoundation |
| **ML/Vision** | Vision Framework + Core ML |
| **Networking** | Multipeer Connectivity |
| **Testing** | XCTest |

## การพัฒนา

### Prerequisites

- macOS 13+ with Xcode 15+
- iOS 16+ devices (iPhone สำหรับกล้อง, iPad/Mac สำหรับประมวลผล)

### Build และ Test

```bash
# Test Swift Package
cd BadmintonCore
swift test

# Build Camera App (ต้องเปิดใน Xcode)
open BadmintonCamera/BadmintonCamera.xcodeproj

# Build Tracker App (ต้องเปิดใน Xcode)
open BadmintonTracker/BadmintonTracker.xcodeproj
```

### การใช้งาน

1. เปิด **BadmintonCamera** บน iPhone
2. เปิด **BadmintonTracker** บน iPad หรือ Mac
3. ใน Tracker App: ตั้งค่าชื่อผู้เล่นและ best of X
4. เชื่อมต่อกับ Camera (อุปกรณ์จะค้นหากันอัตโนมัติ)
5. วางกล้อง iPhone มุมที่เห็นสนามทั้งหมด
6. กด "Start Tracking" และเริ่มเล่น!

## License

This project is for educational purposes.

## หมายเหตุ

- ต้องใช้อุปกรณ์จริง (ไม่สามารถใช้ simulator ได้เต็มรูปแบบเพราะต้องใช้กล้อง)
- แนะนำให้ใช้ WiFi เดียวกันสำหรับการเชื่อมต่อที่เสถียร
- การตรวจจับลูกขนไก่อาจต้อง tune parameters ให้เหมาะกับแสงและสนาม
