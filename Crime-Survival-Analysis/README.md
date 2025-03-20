# 🔍 범죄 데이터 분석: 생존 분석을 활용한 검거 기간 예측

📅 **프로젝트 기간**: 2022년 2학기 '생존분석' 전공과목  
🛠 **사용 기술**: R, 생존 분석(Survival Analysis), Kaplan-Meier 분석, Cox 회귀모델  

📊 **데이터 출처**: [경찰청 범죄통계](https://www.police.go.kr/user/bbs/BD_selectBbsList.do?q_bbsCode=1115&estnColumn2=%EB%85%84%EB%8F%84)  

---

## 🔹 프로젝트 개요

이 프로젝트는 **범죄 유형별 검거 기간을 예측**하는 생존 분석을 수행하는 것이 목표입니다.  
특히, **범죄 발생 후 검거까지 걸리는 시간(생존 시간)을 다양한 변수(연령, 지역, 범죄 유형 등)를 고려하여 분석**하였습니다.  

**🎯 연구 목적**
- 범죄 유형에 따라 검거 확률과 시간이 다르게 나타나는지 분석  
- Kaplan-Meier 생존 곡선을 통해 검거 확률 시각화  
- Cox 회귀 모델을 적용하여 주요 영향 요인 도출  

---

## 🔹 데이터 소개

본 연구에서는 **범죄 발생 및 검거 데이터를 사용**하였으며, 주요 변수는 다음과 같습니다.  

📌 **데이터 주요 변수**:
- `crime2`: 범죄 유형 (예: 절도, 폭력, 마약 등)  
- `time`: 범죄 발생 후 검거까지 걸린 기간  
- `Probability`: 검거 비율  

---

## 🔹 분석 과정

### **1️⃣ 데이터 탐색 및 전처리**
- 이상치 탐색 및 결측치 처리  
- 생존 분석을 위한 데이터 변환 (Censoring 고려)  

### **2️⃣ 생존 분석 수행**
- **Kaplan-Meier 생존 곡선 분석**  
  - 범죄 유형별 생존 곡선 비교  
  - Log-rank 검정을 활용한 그룹 간 차이 분석  

---

## 🔹 분석 결과

### **📌 주요 인사이트**
1️⃣ **범죄 유형별 검거 확률 차이**  
- 강력 범죄는 상대적으로 검거 확률이 높음  
- 위조범죄, 공무원 범죄의 경우 장기 미검거 확률이 가장 높음  

---

## 🔹 시각화 결과

📊 프로젝트에서 사용한 주요 그래프  
- **범죄 유형별 검거율**  
![검거율](https://github.com/L0326-S/Portfolio/blob/main/Crime-Survival-Analysis/images/검거율.png)
- **Kaplan-Meier 생존 곡선 (범죄 유형별 검거 확률 비교)**  
![강력범죄](https://github.com/L0326-S/Portfolio/blob/main/Crime-Survival-Analysis/images/강력범죄.png)
![재산범죄](https://github.com/L0326-S/Portfolio/blob/main/Crime-Survival-Analysis/images/재산범죄.png)

📌 **상세한 분석 결과는 [코드 파일](./crime_analysis.R)에서 확인 가능!**
