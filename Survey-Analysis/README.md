# 🎸 서울대학교 밴드 동아리 경험자의 가입 동기 및 활동 만족도 분석

📅 **프로젝트 기간**: 2024년 1학기 '표본설계 및 조사실습' 전공과목  
🛠 **사용 기술**: R, 설문조사, 요인 분석(Factor Analysis), 분산분석(ANOVA), 회귀 분석  

📊 **데이터 출처**: 직접 설문조사 (서울대학교 중앙 및 단과대 밴드 동아리)  

👤 **담당 역할**:  
- **데이터 시각화**: 설문 결과를 기반으로 주요 분석 결과 그래프 생성  
- **요인분석 및 분산분석**: 설문 결과에 영향을 주는 요인들에 대해 분석 

---

## 🔹 프로젝트 개요

본 연구는 **서울대학교 교내 밴드 동아리 활동 경험자의 가입 동기와 만족도를 분석**하는 것을 목표로 합니다.  
특히, **가입 전 기대와 실제 만족도의 차이를 요인 분석, 분산 분석, 회귀 분석을 통해 분석**하였습니다.  

**🎯 연구 목적**
- 밴드 동아리 가입 동기 및 기대 요인 분석  
- 가입 후 활동 만족도를 결정짓는 요인 도출  
- 인적 사항(임원 여부, 활동 기간 등)에 따른 만족도 차이 검증  

---

## 🔹 데이터 소개

본 연구는 **서울대학교 중앙 및 단과대 밴드 동아리 경험자를 대상으로 설문조사**를 실시하였으며, 주요 변수는 다음과 같습니다.  

📌 **데이터 주요 변수**:
- `before_f1` ~ `before_f4`: 가입 전 기대 요인 (친목, 음악/문화, 공연, 조직 생활)  
- `f1` ~ `f4`: 가입 후 만족도 요인 (친목, 음악/문화, 공연, 조직 생활)  
- `satisfaction`: 종합 만족도  
- `position`: 활동 포지션 (보컬, 기타, 키보드 등)  
- `leader`: 임원 경험 여부 (1 = 있음, 0 = 없음)  
- `duration`: 활동 기간 (6개월 미만 ~ 2년 이상)  

---

## 🔹 분석 과정

### **1️⃣ 데이터 탐색 및 전처리**
- 크론바흐 알파(Cronbach’s Alpha) 분석을 통한 신뢰도 검토  
- 기대도 및 만족도 문항별 평균 비교 (EDA)  
- 이상치 탐색 및 결측치 처리  

### **2️⃣ 요인 분석 (Factor Analysis)**
- Exploratory Factor Analysis (EFA)  
- Confirmatory Factor Analysis (CFA)  
- 병렬 분석을 통한 최적 요인 개수 선정  

### **3️⃣ 분산 분석 (ANOVA)**
- 활동 기간, 동아리 규모, 성별, 임원 경험 여부에 따른 만족도 차이 분석  
- Levene 검정을 이용한 등분산성 검토  
- Welch’s ANOVA를 활용한 차이 검증  

### **4️⃣ 회귀 분석 (Regression Analysis)**
- 다중선형회귀 (Multiple Linear Regression)를 활용한 종합 만족도 예측  
- 인적 사항(임원 여부, 활동 기간 등)과 만족도의 관계 분석  

---

## 🔹 분석 결과

### **📌 주요 인사이트**
1️⃣ **기대도 대비 만족도 차이**  
- 가입 전 기대보다 가입 후 만족도가 전반적으로 더 높음  
- 특히 친목과 조직 생활 만족도의 상승 폭이 큼  

2️⃣ **임원 경험이 만족도에 미치는 영향**  
- 임원 경험자는 일반 회원보다 만족도가 유의미하게 높음  
- 특히 친목, 공연, 조직 생활 만족도에서 큰 차이를 보임  

3️⃣ **활동 기간과 만족도의 관계**  
- 활동 기간이 길수록 만족도가 높아지는 경향  
- 그러나 6개월 이상일 경우 증가폭이 완만해짐  

4️⃣ **음악/문화 활동 만족도는 동아리 규모에 영향을 받음**  
- 소규모 동아리일수록 음악/문화 활동 만족도가 높음  

5️⃣ **성별에 따른 만족도 차이 없음**  
- 성별은 친목, 음악/문화, 공연, 조직 생활 만족도에 유의미한 영향을 미치지 않았지만 전체적인 만족도에서 차이를 보임임

---

## 🔹 시각화 결과

📊 프로젝트에서 사용한 주요 그래프  
- **기대도 vs. 만족도 비교 그래프**  
![공연 만족도](https://github.com/L0326-S/Portfolio/blob/main/Survey-Analysis/images/공연만족도.png)
![음악 만족도](https://github.com/L0326-S/Portfolio/blob/main/Survey-Analysis/images/음악만족도.png)
![조직 만족도](https://github.com/L0326-S/Portfolio/blob/main/Survey-Analysis/images/조직만족도.png)
![친목 만족도](https://github.com/L0326-S/Portfolio/blob/main/Survey-Analysis/images/친목만족도.png)
![종합 만족도](https://github.com/L0326-S/Portfolio/blob/main/Survey-Analysis/images/종합만족도.png)
![상관계수 시각화](https://github.com/L0326-S/Portfolio/blob/main/Survey-Analysis/images/만족도상관계수.png)
- **탐색적 요인분석(EFA)**  
![EFA result](https://github.com/L0326-S/Portfolio/blob/main/Survey-Analysis/images/EFAresult.png)
![Scree Plots](https://github.com/L0326-S/Portfolio/blob/main/Survey-Analysis/images/screeplot.png)
요인분석 결과 최초에 설계한 설문지의 4가지 유형과 거의 유사하므로 요인별로 잘 나뉘어졌다 가정하고, 하나의 요인으로 묶인 문항의 만족도의 평균을 각 요인의 값으로 분석함함
- **ANOVA 분석결과 시각화**  
![임원유무](https://github.com/L0326-S/Portfolio/blob/main/Survey-Analysis/images/임원유무.png)
![활동기간](https://github.com/L0326-S/Portfolio/blob/main/Survey-Analysis/images/활동기간.png)
![활동유무](https://github.com/L0326-S/Portfolio/blob/main/Survey-Analysis/images/활동유무.png)
![활동인원](https://github.com/L0326-S/Portfolio/blob/main/Survey-Analysis/images/활동인원.png)
![성별](https://github.com/L0326-S/Portfolio/blob/main/Survey-Analysis/images/성별.png)

📌 **상세한 분석 결과는 [코드 파일](./Data_analysis.Rmd)에서 확인 가능!**
