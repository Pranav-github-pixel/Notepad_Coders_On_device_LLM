# Samsung EnnovateX 2025 AI Challenge Submission

- **Problem Statement** - *(On-Device Fine-Tuning Framework for Billion+ Parameter scale LLMs
Efficient framework for the on-device fine-tuning of Billion+ scale Large Language Models on a Galaxy S23-S25 equivalent smartphone/edge device. Enable a typical application to adapt a pre-trained LLM to a user's personal data, all while operating within the tight constraints of a mobile environment.)*
- **Team name** - *Notepad_Coders*
- **Team members** - *Pranav Satish Khadse*, *Rishi Jain*, *Kulin Mathur*, *Apratim Jha* 
- **Demo Video Link** - *(Upload the Demo video on Youtube as a public or unlisted video and share the link. Google Drive uploads or any other uploads are not allowed.)*


### Project Artefacts

# Project Title

## Repository Structure

- **Technical Documentation** - [Docs](docs)  
  All technical details are written in markdown files inside the `docs/` folder.

- **Source Code** - [Source](src)  
  The complete source code resides in the `src/` folder.  
  The code is installable/executable and runs consistently on the intended platforms.

- **Models Used**  
  - [Phi-3 Mini (4k Instruct, GGUF)](https://huggingface.co/microsoft/Phi-3-mini-4k-instruct)  
  *(You are permitted to use open-weight models hosted on Hugging Face.)*

- **Models Published**  
  *(If you have trained or fine-tuned a custom model, upload it on Hugging Face under an appropriate open-source license and add the link here.)*

- **Datasets Used**  
  *(Links to all publicly available datasets under Creative Commons, Open Data Commons, or equivalent license.)*  
  Example: [Common Crawl](https://commoncrawl.org/)

- **Datasets Published**  
  *(If you have created synthetic or proprietary datasets, publish them on Hugging Face under a suitable open license and add the link here.)*

---

## Tech Stack

- **Frontend / UI**: Flutter  
- **Languages**: Dart, Kotlin/Java (for Android integration), C++ (FFI bindings if needed)  
- **ML Inference**: [MLC LLM](https://github.com/mlc-ai/mlc-llm) (GGUF model support)  
- **Model Storage**: Device-local storage (`getApplicationDocumentsDirectory`)  
- **Dependency Management**: pub.dev (Flutter), Gradle (Android)  
- **Platforms Supported**: Android (tested), Web/Desktop (with modifications)  
- **Model Format**: GGUF (quantized LLMs)  
- **Datasets**: Open-source datasets (if applicable, links above)  
- **Version Control**: Git + GitHub  

---
### Attribution 

In case this project is built on top of an existing open source project, please provide the original project link here. Also, mention what new features were developed. Failing to attribute the source projects may lead to disqualification during the time of evaluation.
