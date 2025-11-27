# การติดตั้งและใช้งาน Badminton Auto-Tracking System

## ⚙️ ข้อกำหนดของระบบ

- **macOS** 13+ พร้อม **Xcode** 15+
- **iPhone** ที่มี iOS 16+ (สำหรับกล้อง)
- **iPad** หรือ **Mac** ที่มี iPadOS 16+ หรือ macOS 13+ (สำหรับประมวลผล)
- อุปกรณ์ทั้งสองต้องอยู่ใน **WiFi เครือข่ายเดียวกัน** (แนะนำ)

---

## 📦 โครงสร้างโปรเจค

```
badminton/
├── BadmintonCore/              # Swift Package (ใช้ร่วมกัน)
├── BadmintonCamera/            # App สำหรับ iPhone  
└── BadmintonTracker/           # App สำหรับ iPad/Mac
```

---

## 🚀 การ Build และ Run

### 1. เปิดโปรเจคใน Xcode

เนื่องจากโค้ดที่สร้างมาเป็นไฟล์ Source Code เท่านั้น คุณต้อง**สร้าง Xcode Project** เอง:

#### สำหรับ BadmintonCamera (iOS App)

```bash
# ใน Xcode:
1. File → New → Project
2. เลือก iOS → App
3. ตั้งชื่อ "BadmintonCamera"
4. Interface: SwiftUI
5. Language: Swift
6. คัดลอกไฟล์จาก BadmintonCamera/ ไปยัง project
7. เพิ่ม BadmintonCore เป็น Swift Package dependency:
   - File → Add Package Dependencies
   - Add Local... → เลือก BadmintonCore folder
```

#### สำหรับ BadmintonTracker (Multi-platform App)

```bash
# ใน Xcode:
1. File → New → Project
2. เลือก Multiplatform → App
3. ตั้งชื่อ "BadmintonTracker"
4. Interface: SwiftUI 
5. Language: Swift
6. เลือก platforms: iOS, iPadOS, macOS
7. คัดลอกไฟล์จาก BadmintonTracker/ ไปยัง project
8. เพิ่ม BadmintonCore เป็น dependency (เหมือนข้างบน)
```

### 2. ติดตั้ง Dependencies

BadmintonCore เป็น local Swift Package ดังนั้นไม่ต้องติดตั้งอะไรเพิ่ม

### 3. กำหนด Code Signing

- เปิด project settings
- เลือก Signing & Capabilities
- เลือก Team ของคุณ
- ตรวจสอบ Bundle Identifier (ต้องไม่ซ้ำกัน)

### 4. Build และ Deploy

**Camera App** (ต้องใช้อุปกรณ์จริง):
```bash
1. เชื่อมต่อ iPhone เข้ากับ Mac
2. เลือก iPhone เป็น deployment target
3. กด Run (⌘ + R)
4. อนุญาต permissions (Camera, Local Network) เมื่อขอ
```

**Tracker App** (ใช้ simulator หรืออุปกรณ์จริง):
```bash
1. เลือก iPad simulator หรืออุปกรณ์จริง
2. กด Run (⌘ + R)
3. อนุญาต Local Network permission
```

---

## 📱 วิธีใช้งาน

### การเริ่มต้น

1. **เปิด BadmintonCamera บน iPhone**
   - รอให้แสดง "Advertising as camera..."
   - กล้องจะเริ่มทำงานอัตโนมัติ

2. **เปิด BadmintonTracker บน iPad/Mac**
   - หน้าจอ Match Setup จะปรากฏ

3. **กรอกข้อมูลการแข่งขัน**
   - ชื่อ Player A และ Player B
   - เลือก Best of 3 หรือ 5
   - กด "Connect Camera"

4. **เชื่อมต่อกล้อง**
   - ใน Camera Connection sheet จะเห็น iPhone ของคุณ
   - กดเพื่อเชื่อมต่อ
   - รอจนกว่าจะแสดง "Camera Connected"

5. **วางกล้อง iPhone**
   - วาง iPhone บนขาตั้งหรือที่วางมือถือ
   - มุมกล้องต้องเห็นสนามแบดมินตันทั้งหมด
   - แนะนำให้วางด้านข้างสนามตรงกลาง

6. **เริ่มแม็ตช์**
   - กด "Start Match" บน iPad/Mac
   - แอปจะพร้อมนับคะแนน

### ระหว่างการเล่น

1. **เริ่ม Rally**
   - กด "Start Tracking" หรือ "Detect Rally End"
   - ระบบจะวิเคราะห์วิดีโอ

2. **AI Suggestion**
   - เมื่อระบบตรวจจับการจบของ rally จะแสดง suggestion
   - แสดงผู้ชนะ, เหตุผล (IN/OUT/NET), และความมั่นใจ (confidence)
   - กด **Confirm** เพื่อยอมรับ หรือ **Reject** เพื่อปฏิเสธ

3. **Manual Override**
   - ถ้า Reject AI suggestion จะแสดงหน้าจอ Manual Override
   - เลือก Point A, Point B, หรือ LET
   - กด Cancel เพื่อยกเลิก

4. **Undo/Redo**
   - ใช้ปุ่ม Undo/Redo ด้านล่างเพื่อแก้ไขคะแนน

### จบเกม/จบแม็ตช์

- เมื่อเกมจบ จะแสดงหน้าจอ Game End
- กด "Start Next Game" เพื่อเริ่มเกมถัดไป
- เมื่อแม็ตช์จบ จะแสดง Match End พร้อมผลรวม
- กด "Start New Match" เพื่อเริ่มแม็ตช์ใหม่

---

## 🧪 การทดสอบ

### Unit Tests (BadmintonCore)

```bash
cd BadmintonCore
swift test
```

ควรเห็นผลการ test ทั้งหมดผ่าน (Passed) โดยครอบคลุม:
- Scoring rules (21 points, deuce, best of 3/5)
- Serving court calculation
- Game over conditions
- Match winner determination

---

## ⚠️ ข้อควรระวังและข้อจำกัด

### ข้อจำกัดปัจจุบัน

1. **ML Detection เป็น Placeholder**
   - ตอนนี้ยังไม่มี Core ML model สำหรับตรวจจับลูกขนไก่
   - Vision Framework ตรวจจับผู้เล่นได้ แต่ยังไม่ใช้ในการวิเคราะห์
   - Rally detection ใช้การจำลองแบบสุ่ม (random)
   - **ต้องพัฒนาต่อ**: train หรือหา shuttlecock detection model

2. **Video Streaming**
   - ใช้ JPEG compression (quality 0.6)
   - Effective frame rate ~30fps
   - อาจมี latency ถ้า WiFi ไม่เสถียร

3. **Court Detection**
   - ยังไม่มีการตรวจจับเส้นสนาม
   - ไม่สามารถแยก IN/OUT ได้แม่นยำ

### การแก้ไขปัญหาที่พบบ่อย

**ไม่มีกล้องปรากฏใน discovered devices:**
- ตรวจสอบว่าทั้งสองอุปกรณ์อยู่ใน WiFi เดียวกัน
- ตรวจสอบ Local Network Permission
- ลอง restart ทั้งสองแอป

**Video streaming ช้า:**
- ใช้ WiFi 5GHz
- ลดความละเอียดกล้อง (แก้ใน CameraManager)
- เพิ่ม compression quality

**AI detection ไม่แม่นยำ:**
- ปกติครับ เพราะยังไม่มี ML model จริง
- ต้องใช้ Manual Override

---

## 🔮 การพัฒนาต่อ (Roadmap)

### ลำดับความสำคัญสูง

1. **Shuttlecock Detection Model**
   - Train YOLOv8 model บน badminton footage
   - Convert เป็น Core ML format
   - Integrate เข้า VisionProcessor

2. **Court Line Detection**
   - ใช้ VNDetectRectanglesRequest
   - Calibrate court boundaries
   - Map shuttlecock position to court coordinates

3. **Rally Detection Logic**
   - Track shuttlecock trajectory
   - Detect ground contact
   - Calculate IN/OUT based on court boundaries

### ลำดับความสำคัญปานกลาง

4. **Video Recording**
   - บันทึกวิดีโอแม็ตช์
   - Save with score overlay
   - Replay functionality

5. **Statistics**
   - Rally duration
   - Point analysis
   - Player performance metrics

6. **Cloud Sync**
   - iCloud integration
   - Match history
   - Cross-device sync

---

## 📖 เอกสารเพิ่มเติม

- **Architecture**: ดู `implementation_plan.md` สำหรับรายละเอียดสถาปัตยกรรม
- **Scoring Rules**: ดู `ScoringEngine.swift` สำหรับกฎแบดมินตัน
- **Network Protocol**: ดู `NetworkProtocol.swift` สำหรับ message format

---

## 🙏 Credits

- **Vision Framework**: Apple's computer vision framework
- **Multipeer Connectivity**: Apple's P2P networking
- **SwiftUI**: Modern UI framework

---

## 📝 License

This project is for educational purposes.
