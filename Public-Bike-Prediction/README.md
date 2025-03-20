# 🚲 서울시 공공자전거 이용 패턴 분석
**서울시 '따릉이' 이용자 수 데이터를 기반으로 한 시계열 분석 프로젝트**  
📅 **프로젝트 기간**: 2024년  
🛠 **사용 기술**: R, 시계열 분석, ARIMA, 데이터 시각화  
📊 **데이터 출처**: [서울 열린데이터광장](https://data.seoul.go.kr/)

---

## 🔹 프로젝트 개요
서울시에서 운영하는 공공자전거 '따릉이'의 이용 패턴을 분석하고, 수요를 예측하기 위해 시계열 분석을 수행하였습니다.  
특히, **정기권 이용자와 일일권 이용자의 차이를 분석하고, 기온과 강수량 등 외부 변수의 영향을 고려하여 예측 모델을 개발**하였습니다.

**🎯 연구 목적**
- 공공자전거 이용 패턴을 정기권 vs. 일일권으로 구분하여 분석
- 시계열 모델을 활용해 미래 수요 예측
- 기온 및 강수량 등 외생변수를 반영한 최적의 예측 모델 도출

---

## 🔹 데이터 소개
본 연구에서는 서울 열린데이터광장에서 제공하는 **'서울시 공공자전거 이용정보(일별)'** 데이터를 사용하였습니다.

📌 **데이터 주요 변수**:
- `date`: 날짜 (YYYY-MM-DD)
- `total_rentals`: 총 대여 건수
- `season_pass_rentals`: 정기권 대여 건수
- `one_day_pass_rentals`: 일일권 대여 건수
- `temperature`: 일평균 기온 (℃)
- `precipitation`: 강수량 (mm)

📌 **추가 데이터**:
- `holidays`: 공휴일 정보 (한국천문연구원 제공)
- `day_of_week`: 요일 정보

---

## 🔹 분석 과정
### **1️⃣ 데이터 탐색 및 전처리**
- 이상치 탐색 (1.5 IQR 방식)
- 주기성 분석 (Lag Plot, ACF Plot)
- 기상 데이터 병합

### **2️⃣ 시계열 모델 적합**
- 기본 SARIMA(Seasonal ARIMA) 모델 적합
- 정기권: **SARIMA(0,1,2)(0,0,2)₇** 모델 선택
- 일일권: **ARIMA(4,1,1)** 모델 선택
- Box-Cox 변환을 이용한 분산 안정화

### **3️⃣ 외생변수 추가 및 최적 모델 선정**
- `Regression with ARIMA errors` 모델 적용
- 기온, 강수량을 포함한 모델이 AIC, BIC 기준 더 우수한 예측 성능을 보임
- 최종 모델: **Regression with ARIMA errors (외생변수 포함)**

---

## 🔹 분석 결과
### **📌 주요 인사이트**
1️⃣ **따릉이 이용 패턴은 정기권과 일일권 간에 차이가 있다.**  
![따릉이 이용량 변화](https://github.com/L0326-S/Portfolio/blob/main/Public-Bike-Prediction/images/season_oneday.jpeg)
   - 정기권 이용자는 출퇴근 시간(평일 아침, 저녁) 중심으로 사용  
   - 일일권 이용자는 날씨 영향을 더 크게 받으며 주말에 사용 증가  

2️⃣ **날씨가 따릉이 이용량에 영향을 미친다.**  
![날씨에 따른 이용량 변화](https://github.com/L0326-S/Portfolio/blob/main/Public-Bike-Prediction/images/weather.jpeg)
   - 기온이 높을수록 이용량 증가 → 하지만 20℃ 이상에서는 일일권 사용 감소  
   - 강수량이 증가하면 이용량이 급감 (비가 오면 따릉이 사용 줄어듦)  

3️⃣ **최적 예측 모델은 외생변수를 포함한 Regression with ARIMA errors 모델이다.**  
   - 외생변수를 추가했을 때 AIC, BIC가 더 낮아 예측력이 향상됨  
![정기권](https://github.com/L0326-S/Portfolio/blob/main/Public-Bike-Prediction/images/seasonpass.jpeg)
![일일권](https://github.com/L0326-S/Portfolio/blob/main/Public-Bike-Prediction/images/onedaypass.jpeg)

---

## 🔹 시각화 결과
📊 프로젝트에서 사용한 주요 그래프  
- **따릉이 이용량의 주기성 (7일 단위)**
- **기온 vs. 따릉이 이용량 관계**
- **강수량 vs. 따릉이 이용량 관계**
- **시계열 분해 결과 (STL decomposition)**

📌 **상세한 분석 결과는 [코드 파일](./analysis_code.R)에서 확인 가능!**
