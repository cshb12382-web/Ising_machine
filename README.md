# Ising_machine
Max-Cut 등 NP-hard 조합 최적화 문제를 고속으로 해결하기 위한 FPGA 기반 이징 머신(Ising Machine) 하드웨어 가속기 설계



# 🚀 High-Performance FPGA Ising Machine for Combinatorial Optimization

> FPGA-based Hardware Annealer featuring Incremental Local-Field Updates & Hybrid RO-TRNG

## 💡 Project Overview

본 프로젝트는 Max-Cut 등 NP-hard 조합 최적화 문제를 고속으로 해결하기 위한 FPGA 기반 이징 머신(Ising Machine) 하드웨어 가속기 설계입니다.
기존 폰노이만 구조에서 발생하는 메모리 대역폭 한계를 극복하기 위해 Incremental Local-Field Update 아키텍처를 도입하였으며, 알고리즘이 Local Minimum에 빠지는 현상을 방지하기 위해 칩 내부의 물리적 열 잡음(Thermal Noise)을 활용한 하이브리드 RO-TRNG를 자체 설계중입니다.
(1단계 : LFSR, 2단계 : RO-TRNG, 3단계 : MRAM_TRNG)

## 🔑 Key Architectures & Optimizations

* **Complexity Incremental Update Pipeline**
* 매 사이클마다 전체를 재계산하는 기존 방식의 메모리 병목을 해소.
* 상태가 변이된 단일 스핀의 가중치만을 BRAM에서 읽어와 덧셈기 기반으로 레지스터를 동시 갱신하는 델타 업데이트 로직 구현.


* **Heterogeneous RO-TRNG & Hybrid Random Number Generation**
* 3-stage, 5-stage, 7-stage 등 인버터 개수가 서로 다른 링 오실레이터를 배치하여 주파수 위상 고정 현상 원천 차단.
* 다중 주파수 믹싱을 통해 추출한 순수 물리적 난수를 결합.



## 🛠️ Hardware Troubleshooting & Debugging

1. **BRAM Read Latency Synchronization (파이프라인 동기화):**
* **Issue:** 1-Clock 지연으로 인한 타겟 주소와 데이터의 엇갈림 발생.
* **Solution:** FSM 상태를 분리하여 메모리 read latency를 파이프라인에 은닉시킴.

2. **Synthesis Constraint Optimization:**
* **Issue:** Vivado 합성 툴이 RO-TRNG의 조합 논리 루프를 버그로 인식하여 최적화 과정에서 삭제.
* **Solution:** `(* ALLOW_COMBINATORIAL_LOOPS = "TRUE", KEEP = "TRUE" *)` 속성 및 `.xdc` 제약 조건을 명시적으로 부여하여 하드웨어 인스턴스 강제 유지 성공.


## 💻 Tech Stack

* **Hardware:** Verilog HDL, Xilinx Vivado, FPGA
* **Software / Analysis:** C, Python (Data pre-processing, Baseline constant generation)

---
