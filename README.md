# ShantiAI

### A Hybrid Offline–Online Elderly Care Assistant 

Shanti AI is an accessibility-focused, voice-driven assistant designed to help elderly individuals interact with smartphones more comfortably and independently. It combines powerful offline features for reliability with online AI capabilities for advanced reasoning and understanding.

Shanti functions through hands-free activation using the wake word “Shanti”, making it easy and intuitive for seniors to use.


---
## **Features**

### _Core Voice Interaction_

    * Wake-word activation: “Shanti”
    
    * Simple, slow, and clear voice responses for elderly users
  
    * Voice-based navigation for phone apps and settings
  
    * Error-resistant dialogue handling



### <ins> **Offline Features** </ins>

Shanti is designed to remain functional even without connectivity.

#### 1. **Offline Speech Processing**

* Offline speech-to-text using Vosk or similar lightweight models

* Offline text-to-speech using built-in Android TTS

#### 2. **Offline Camera Assistance**

* Live camera OCR using ;;;; Tesseract or ML Kit (offline mode)

* OCR on uploaded images, screenshots, or gallery media

* Offline reading aloud of extracted text

#### 3. **Offline Vision Tasks**

* Basic offline image labeling or description 

* Offline face recognition for identifying trusted faces

#### 4. **Offline Navigation & Commands**

 * Rule-based commands for tasks lik Opening apps, Scrolling, Describing buttons, Moving back, Providing step-by-step guidance etc.




### <ins> Online Features </ins>

When internet is available, Shanti becomes more intelligent:

* Advanced image understanding and scene descriptions

* Summaries of documents, forms, bills, prescriptions

* Multi-step form guidance with reasoning

* Conversational assistance

* Smart digital help (“What does this mean?”, “Explain this option”)

Shanti automatically falls back to offline mode if internet drops.

---

## Hybrid Architecture

#### Shanti uses a _dual-mode_ design:

> ### **Offline Mode** [Default]
>
> _**Handles**_:
> 
> **Speech recognition, TTS, OCR, Face recognition, Basic commands**
>
> ### **Online Mode**
>
> _Only activates when:_
>
> **Summaries, Smart explanations, Long-complex reasoning, Advanced vision tasks are requested**

Shanti automatically routes tasks depending on connectivity.

---

###  **Privacy & Safety**

* Offline-first design keeps sensitive data on-device

* No unnecessary uploads

* Trusted face recognition gives comfort & safety

* Confirmation prompts before sensitive actions like calling or messaging

---

## **Future Plans**

1. _More Languages_

    * Extend voice support to all major Indian languages and global languages.
    * Includes offline STT/TTS models for regional languages.

2. _Fully On-Device LLM_

    Move towards:
    
    * On-device reasoning
    
    * On-device multimodal understanding
    
    * Full offline conversational flow

3. _OS-Level Integration_

    Goal:
    Integrate Shanti as a system-wide accessibility layer, not just an app.
   
    Enable features like:

      * Controlling settings
      
      * Speaking system UI text
      
      * Direct OS hooks for navigation
      
      * Full voice accessibility experience for seniors

5. _Smart Reminders & Memory_

      * What user saw earlier
      
      * Daily tasks
      
      * Medicine reminders
      
      * Family contacts prioritization

6. _Sensor-Based Elderly Safety Features_

      * Fall detection
      
      * Location-based alerts (completely offline)
      
      * Ambient noise monitoring
  
---

## Current Limitations: 

#### 1. Limited Offline Reasoning

* Complex summaries, explanations, and multi-step guidance still require an internet connection.

#### 2. Basic Offline Vision Capabilities

* Offline image descriptions are limited to simple labels; detailed scene understanding is not available offline.

#### 3. Wake Word Sensitivity

* The wake word may be less accurate in noisy environments or with very soft speech.

#### 4. Performance on Low-End Devices

* OCR, face recognition, and continuous wake-word listening may cause lag or higher battery consumption on low-spec devices.

#### 5. Limited Language Support

* Currently supports only **English** and **Hindi**.
* Multilingual support is not yet included.

### **6. No Long-Term Memory**

* Shanti does not store or remember interactions across sessions.

---
### Made with 💗 for YuviAI
