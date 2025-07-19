//
//  PremiumCalendarView.swift
//  ClockOutFairy
//
//  Created by myungsun on 7/19/25.
//

import SwiftUI

struct PremiumCalendarView: View {
    // UserDefaults에 데이터를 저장할 때 사용할 키입니다.
    private static let highlightedDaysKey = "highlightedDaysData"
    
    // ContentView로부터 하이라이트 정보를 Binding으로 받습니다.
    @State private var highlightedDays: [Int: HighlightType] = [:]
    
    // 현재 캘린더가 표시하는 월의 첫 날짜를 저장합니다.
    @State private var calendarDate: Date = Date()
    
    // Picker에서 선택될 연도와 월을 저장합니다.
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    
    // 현재 단일 선택된 날짜 (파란색 하이라이트)를 저장하는 새로운 @State 변수입니다.
    // 이 변수는 highlightedDays와 독립적으로 관리됩니다.
    @State private var currentlySelectedDay: Int? = Calendar.current.component(.day, from: Date()) // 초기에는 오늘 날짜 선택
    
    // 퇴근 종류 Picker의 현재 선택값을 저장합니다.
    @State private var selectedLeaveTypeString: String = "없음"
    
    // 현재 캘린더가 표시하는 월의 날짜들을 계산합니다.
    private var daysInMonth: [Int] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: calendarDate) else { return [] }
        return Array(range.lowerBound..<range.upperBound)
    }
    
    // 현재 캘린더가 표시하는 월의 첫 날의 요일 인덱스를 계산합니다 (일요일: 1, 월요일: 2, ..., 토요일: 7).
    private var firstWeekdayOfMonth: Int {
        let calendar = Calendar.current
        guard let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: calendarDate)) else { return 1 }
        return calendar.component(.weekday, from: firstDayOfMonth)
    }
    
    private let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        return formatter
    }()
    
    
    @State private var date = Date()
    
    let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    
    // 현재 선택된 날짜에 따라 Picker에 표시될 퇴근 종류 옵션들을 반환합니다.
    private var leaveTypeOptions: [String] {
        guard let day = currentlySelectedDay else { return ["없음"] }
        
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = selectedYear
        dateComponents.month = selectedMonth
        dateComponents.day = day
        
        guard let fullDate = calendar.date(from: dateComponents) else { return ["없음"] }
        
        // 오늘 날짜를 기준으로 미래 날짜인지 확인합니다.
        let today = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: fullDate)
        
        if targetDate > today { // 미래 날짜인 경우
            return ["없음"]
        } else { // 오늘 또는 과거 날짜인 경우
            return ["없음", "정시 퇴근", "야근", "연차(반차)"]
        }
    }
    
    // NavigationLink의 View 부분입니다.
    var body: some View{
        VStack {
            // 월 표시 (현재 캘린더 날짜를 기반으로 동적으로 표시)
            Text(calendarDate, formatter: monthYearFormatter)
                .font(.title)
                .padding(.bottom, 20)
            
            // 요일 헤더
            HStack {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .frame(maxWidth: .infinity) // 각 요일이 동일한 너비를 가지도록 합니다.
                        .foregroundColor(weekday == "일" ? .red : (weekday == "토" ? .blue : .primary)) // 주말 색상 변경 예시
                }
            }
            .padding(.horizontal, 5) // 요일 헤더에도 좌우 패딩을 추가합니다.
            // 날짜 그리드
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                // 첫 주 시작 전 빈 칸 (1일의 요일에 따라 빈 칸 수를 조절)
                // firstWeekdayOfMonth는 1(일)부터 7(토)까지이므로, 1을 빼주면 0부터 6까지의 인덱스가 됩니다.
                ForEach(0..<firstWeekdayOfMonth - 1, id: \.self) { _ in
                    Text("")
                }
                
                // 날짜 표시
                ForEach(daysInMonth, id: \.self) { day in
                    ZStack {
                        Circle()
                        // 현재 선택된 날짜(currentlySelectedDay)가 있으면 파란색으로 우선 표시
                            .fill(currentlySelectedDay == day ? HighlightType.selected.color : (highlightedDays[day]?.color ?? Color.clear))
                            .frame(width: 40, height: 40)
                        
                        Text("\(day)")
                            .font(.body)
                        // 현재 선택된 날짜(currentlySelectedDay)가 있으면 흰색 텍스트로 우선 표시
                            .foregroundColor(currentlySelectedDay == day ? .white : (highlightedDays[day] != nil ? .white : .primary))
                            .frame(width: 40, height: 40) // 텍스트가 원 안에 중앙 정렬되도록 합니다.
                    }
                    .onTapGesture {
                        // 날짜를 탭하면 currentlySelectedDay를 업데이트합니다.
                        if currentlySelectedDay == day {
                            // 이미 선택된 날짜를 다시 탭하면 선택 해제
                            currentlySelectedDay = nil
                        } else {
                            // 다른 날짜를 탭하면 해당 날짜를 선택
                            currentlySelectedDay = day
                        }
                        print("현재 선택된 날짜: \(currentlySelectedDay ?? 0)일")
                        print("영구 하이라이트 날짜들: \(highlightedDays)")
                        // 여기에 선택된 날짜에 대한 정보를 표시하는 로직을 추가할 수 있습니다.
                    }
                }
            }
            .padding(.horizontal) // 그리드 전체에 좌우 패딩을 추가합니다.
            
            // 퇴근 종류 Picker (선택된 날짜가 있을 때만 표시)
            if let selectedDay = currentlySelectedDay {
                HStack {
                    Text("퇴근 종류:")
                        .font(.headline)
                        .padding(.leading)
                    
                    Picker("퇴근 종류", selection: $selectedLeaveTypeString) {
                        ForEach(leaveTypeOptions, id: \.self) { typeString in
                            Text(typeString).tag(typeString)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal, 10) // Picker 내부 패딩
                    .background(RoundedRectangle(cornerRadius: 15).stroke(Color.gray.opacity(0.5), lineWidth: 1)) // 테두리
                    .padding(.trailing) // Picker 외부 패딩
                }
                .padding(.top, 20)
                .onChange(of: selectedLeaveTypeString) { newTypeString in
                    // Picker 선택이 변경될 때 highlightedDays 업데이트
                    if let highlightType = HighlightType.fromDescription(newTypeString) {
                        highlightedDays[selectedDay] = highlightType
                    } else { // "없음"이 선택된 경우
                        highlightedDays.removeValue(forKey: selectedDay)
                    }
                    print("날짜 \(selectedDay)의 하이라이트가 \(newTypeString)으로 변경됨.")
                }
            }
            
            Spacer() // 나머지 공간을 채워 콘텐츠를 상단으로 밀어 올립니다.
            
            
        }
        .padding() // 전체 뷰에 패딩을 추가합니다.
        .navigationTitle("프리미엄 - 캘린더") // 네비게이션 타이틀 (이 뷰가 네비게이션 스택 안에 있을 경우)
        .onAppear {
            // 뷰가 나타날 때 현재 날짜로 Picker를 초기화합니다.
            selectedYear = Calendar.current.component(.year, from: calendarDate)
            selectedMonth = Calendar.current.component(.month, from: calendarDate)
            // 초기 currentlySelectedDay에 따라 Picker 값 설정
            updateLeaveTypePickerSelection()
        }
        .onChange(of: currentlySelectedDay) { _ in
            // currentlySelectedDay가 변경될 때마다 Picker 값 업데이트
            updateLeaveTypePickerSelection()
        }.onAppear {
            // 뷰가 나타날 때 UserDefaults에서 데이터를 불러옵니다.
            loadHighlightedDays()
        }
    }
    // currentlySelectedDay에 따라 퇴근 종류 Picker의 선택을 업데이트하는 함수
    private func updateLeaveTypePickerSelection() {
        guard let day = currentlySelectedDay else {
            selectedLeaveTypeString = "없음"
            return
        }
        
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = selectedYear
        dateComponents.month = selectedMonth
        dateComponents.day = day
        guard let fullDate = calendar.date(from: dateComponents) else {
            selectedLeaveTypeString = "없음"
            return
        }
        
        let today = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: fullDate)
        
        if targetDate > today { // 미래 날짜인 경우
            selectedLeaveTypeString = "없음"
        } else { // 오늘 또는 과거 날짜인 경우
            // highlightedDays에 해당 날짜의 하이라이트 정보가 있으면 그 설명으로, 없으면 "없음"으로 설정
            selectedLeaveTypeString = highlightedDays[day]?.description ?? "없음"
        }
    }
    
    // UserDefaults에서 하이라이트된 날짜 데이터를 불러오는 함수
        private func loadHighlightedDays() {
            if let savedData = UserDefaults.standard.data(forKey: Self.highlightedDaysKey) {
                do {
                    print("영구 하이라이트 날짜들!: \(highlightedDays)")
                    // 저장된 Data를 [Int: HighlightType] 딕셔너리로 디코딩합니다.
                    let decodedData = try JSONDecoder().decode([Int: HighlightType].self, from: savedData)
                    print("영구 하이라이트 날짜들!: \(highlightedDays)")
                    highlightedDays = decodedData
                    print("UserDefaults에서 데이터 불러오기 성공: \(highlightedDays)")
                } catch {
                    print("UserDefaults에서 데이터 디코딩 실패: \(error.localizedDescription)")
                    // 디코딩 실패 시 초기 예시 데이터로 설정
                    setInitialExampleData()
                }
            } else {
                // 저장된 데이터가 없으면 초기 예시 데이터로 설정합니다.
                print("UserDefaults에 저장된 데이터가 없습니다. 초기 예시 데이터로 설정합니다.")
                setInitialExampleData()
            }
        }
    
    // 초기 예시 데이터를 설정하는 함수
        private func setInitialExampleData() {
            // 오늘 날짜는 CustomCalendarGridExample에서 currentlySelectedDay로 관리하므로 여기에 포함하지 않습니다.
            var initialData: [Int: HighlightType] = [
                :
            ]
            // 현재 월의 날짜가 아닌 경우를 대비하여, daysInMonth 범위 내의 날짜만 추가하도록 로직을 추가할 수 있습니다.
            // 현재는 예시이므로 단순하게 설정합니다.

            highlightedDays = initialData
        }
}
