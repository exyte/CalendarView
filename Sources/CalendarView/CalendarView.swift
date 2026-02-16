//
//  CalendarView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 17.04.2025.
//

import SwiftUI
import AnchoredPopup
import Combine

public struct MonthDayBuilderParams {
    public var date: Date
    public var events: [any CalendarEntity]
    public var viewHeight: CGFloat
}

public struct WeekSwitcherDayBuilderParams {
    @ObservedObject var viewModel: WeekCellsModel /// use @ObservedObject to force swiftUI update flow on UIKit components
    public var day: Date
    public var monthDisplayMode: Bool
}

public struct HeaderBuilderParams {
    public var selectedDate: Binding<Date>
    public var displayMode: Binding<CalendarDisplayMode>
    public var anchorDate: Date
    public var tapSelectDisplayModeClosure: ()->()
    public var tapFilterCalendarsClosure: ()->()
    public var tapAddEventClosure: ()->()
}

public struct weekSwitcherDayFooterParams {
    public var selectedDate: Date
    public var daysCount: Int = 1
}

public class CalendarViewCustomizationParams {
    public var hoursToFit: CGFloat = 12
    public var hourLabelFormat: String = "h a"
    public var firstDayOfWeek: Int?

    public var horSpacing: CGFloat = 4
    public var verSpacing: CGFloat = 4
    public var headerBackground: HeaderBackground = .color(.named("headerBG"))
    
    public var isDayInWeekSwitcherPagingEnabled: Bool = false
    
    public var eventDetailsClosure: ((any CalendarEntity)->())?
}

public struct CalendarView<DayEvent: View, MonthDay: View, WeekSwitcherDay: View, Header: View, Footer: View>: View {

    @ViewBuilder var dayEventBuilder: (any CalendarEntity) -> DayEvent
    @ViewBuilder var monthDayBuilder: (MonthDayBuilderParams) -> MonthDay
    @ViewBuilder var weekSwitcherDayBuilder: (WeekSwitcherDayBuilderParams) -> WeekSwitcherDay
    @ViewBuilder var headerBuilder: (HeaderBuilderParams) -> Header
    @ViewBuilder var weekSwitcherDayFooterBuilder: (weekSwitcherDayFooterParams) -> Footer

    @StateObject var viewModel: CalendarViewModel
    
    public init(
        providers: [CalendarsProvider] = [],
        dayEventBuilder: @escaping (_ calendarEvent: any CalendarEntity) -> DayEvent = {
            DefaultDayEventView(entity: $0)
        },
        monthDayBuilder: @escaping (_ params: MonthDayBuilderParams) -> MonthDay = {
            DefaultDayInMonthView(params: $0)
        },
        weekSwitcherDayBuilder: @escaping (_ params: WeekSwitcherDayBuilderParams) -> WeekSwitcherDay = {
            DefaultDayInWeekView(params: $0)
        },
        headerBuilder: @escaping (_ params: HeaderBuilderParams) -> Header = {
            DefaultHeaderView(params: $0)
        },
        weekSwitcherDayFooterBuilder: @escaping (_ params: weekSwitcherDayFooterParams) -> Footer = {
            DefaultWeekSwitcherDayFooterView(params: $0)
        }
    ) {
        self._viewModel = StateObject(wrappedValue: CalendarViewModel(providers: providers))
        self.dayEventBuilder = dayEventBuilder
        self.monthDayBuilder = monthDayBuilder
        self.weekSwitcherDayBuilder = weekSwitcherDayBuilder
        self.headerBuilder = headerBuilder
        self.weekSwitcherDayFooterBuilder = weekSwitcherDayFooterBuilder
    }

    @Environment(\.calendarTheme) var theme

    @BindableValue var selectedDate: Date = Date().startOfDay
    @BindableValue var displayMode: CalendarDisplayMode = .day
    @BindableValue var needUpdate: UUID = UUID()

    @State var anchorDate: Date = Date()
    @State var showCalendarFilters = false
    @State var showCreateEvent = false
    @State var showEventDetails = false
    @State var displayedEventDetails: CalendarEntityWrapper?
    @State var updateID = UUID() // triggers downstream updates
    
    @State var isDragging: Bool = false
    @State var currentPage: Int = 0

    // layout helpers
    @State var hoursLabelsInset: CGFloat = 0

    @State var customizationParams = CalendarViewCustomizationParams()
    
    @State private var currentZoom = 0.0
    @State private var totalZoom = 4.0

    public var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                headerBuilder(HeaderBuilderParams(
                    selectedDate: $selectedDate,
                    displayMode: $displayMode,
                    anchorDate: anchorDate,
                    tapSelectDisplayModeClosure: {
                        AnchoredPopup.launchGrowingAnimation(id: "displayMode")
                    },
                    tapFilterCalendarsClosure: {
                        showCalendarFilters = true
                    },
                    tapAddEventClosure: {
                        showCreateEvent = true
                    })
                )

                DayInWeekSwitcher(selectedDate: $selectedDate, anchorDate: $anchorDate, calendarDisplayMode: displayMode, hoursLabelsInset: hoursLabelsInset, weekSwitcherDayBuilder: weekSwitcherDayBuilder)
                    .padding(8)
                    
            }
            .background {
                HeaderBackgroundView(background: customizationParams.headerBackground)
            }

            switch displayMode {
            case .day:
                GeometryReader { g in
                    InfiniteTabPageView(width: g.size.width, currentPage: $currentPage, didEndAnimation: $viewModel.didEndAnimating, isDragging: $isDragging) { page in
                        let date = Calendar.current.date(byAdding: .day, value: page - currentPage, to: selectedDate) ?? selectedDate
                        
                        VStack(spacing: 0) {
                            weekSwitcherDayFooterBuilder(weekSwitcherDayFooterParams(selectedDate: date))

                            DayLayout(selectedDate: $selectedDate, currentDate: date, hoursLabelsInset: $hoursLabelsInset, daysCount: displayMode == .day ? 1 : 3, events: viewModel.getEvents(from: date, displayMode: displayMode, selectedDate: selectedDate), reminders: [], updateID: updateID, isDragging: $isDragging, dayEventBuilder: dayEventBuilder)
                                .padding(.top, 8)
                                .background(theme.day.background)
                        }
                    }
                    .simultaneousGesture(
                        MagnifyGesture()
                            .onChanged { value in
                                isDragging = true
                                currentZoom = (value.magnification - 1) * 3
                                let hoursToFit = max(3.0, min(currentZoom + totalZoom, 12.0))
                                customizationParams.hoursToFit = hoursToFit
                                updateID = UUID()
                            }
                            .onEnded { value in
                                totalZoom += currentZoom
                                totalZoom = max(3.0, min(12.0, totalZoom))
                                currentZoom = 0
                                isDragging = false
                            }
                            
                    )
                }
                .padding(.top, -8)
            case .twoDays:
                GeometryReader { g in
                    InfiniteTabPageView(width: g.size.width, currentPage: $currentPage, didEndAnimation: $viewModel.didEndAnimating, isDragging: $isDragging) { page in
                        let date = Calendar.current.date(byAdding: .day, value: page - currentPage, to: selectedDate) ?? selectedDate
                        
                        VStack(spacing: 0) {
                            weekSwitcherDayFooterBuilder(weekSwitcherDayFooterParams(selectedDate: date, daysCount: 2))
                            
                            DayLayout(selectedDate: $selectedDate, currentDate: date, hoursLabelsInset: $hoursLabelsInset, daysCount: 2, events: viewModel.getEvents(from: date, displayMode: displayMode, selectedDate: selectedDate), reminders: viewModel.reminders, updateID: updateID, isDragging: $isDragging, dayEventBuilder: dayEventBuilder)
                                .padding(.top, 8)
                                .background(theme.day.background)
                        }
                    }
                    .simultaneousGesture(
                        MagnifyGesture()
                            .onChanged { value in
                                isDragging = true
                                currentZoom = (value.magnification - 1) * 3
                                let hoursToFit = max(3.0, min(currentZoom + totalZoom, 12.0))
                                customizationParams.hoursToFit = hoursToFit
                                updateID = UUID()
                            }
                            .onEnded { value in
                                totalZoom += currentZoom
                                totalZoom = max(3.0, min(12.0, totalZoom))
                                currentZoom = 0
                                isDragging = false
                            }
                        
                    )
                }
                .padding(.top, -8)
            case .threeDays:
                GeometryReader { g in
                    InfiniteTabPageView(width: g.size.width, currentPage: $currentPage, didEndAnimation: $viewModel.didEndAnimating, isDragging: $isDragging) { page in
                        let date = Calendar.current.date(byAdding: .day, value: page - currentPage, to: selectedDate) ?? selectedDate
                        
                        VStack(spacing: 0) {
                            weekSwitcherDayFooterBuilder(weekSwitcherDayFooterParams(selectedDate: date, daysCount: 3))
                            
                            DayLayout(selectedDate: $selectedDate, currentDate: date, hoursLabelsInset: $hoursLabelsInset, daysCount: 3, events: viewModel.getEvents(from: date, displayMode: displayMode, selectedDate: selectedDate), reminders: viewModel.reminders, updateID: updateID, isDragging: $isDragging, dayEventBuilder: dayEventBuilder)
                                .padding(.top, 8)
                                .background(theme.day.background)
                        }
                    }
                    .simultaneousGesture(
                        MagnifyGesture()
                            .onChanged { value in
                                isDragging = true
                                currentZoom = (value.magnification - 1) * 3
                                let hoursToFit = max(3.0, min(currentZoom + totalZoom, 12.0))
                                customizationParams.hoursToFit = hoursToFit
                                updateID = UUID()
                            }
                            .onEnded { value in
                                totalZoom += currentZoom
                                totalZoom = max(3.0, min(12.0, totalZoom))
                                currentZoom = 0
                                isDragging = false
                            }
                        
                    )
                }
                .padding(.top, -8)
            case .month:
                DayInMonthSwitcher(selectedDate: $selectedDate, calendarDisplayMode: $displayMode, monthDayBuilder: monthDayBuilder)
                    .padding(.top, 8)
                    .background(theme.month.background)
            }
        }
        .environmentObject(viewModel)
        .environment(\.calendarCustomizationParams, customizationParams)
        .environment(\.showEventDetailsClosure, { (entity: any CalendarEntity) in
            if let eventDetailsClosure = customizationParams.eventDetailsClosure {
                eventDetailsClosure(entity)
            } else {
                displayedEventDetails = CalendarEntityWrapper(entity)
            }
        })
        .onChange(of: selectedDate, initial: true) {
            anchorDate = selectedDate
            updateData()
        }
        .onChange(of: displayMode) {
            updateData()
        }
        .onChange(of: needUpdate) {
            updateData()
        }
        .onReceive(viewModel.$didEndAnimating) { value in
            let date = selectedDate.adding(.day, value: value)
            
            selectedDate = date
        }

        .sheet(isPresented: $showCalendarFilters) {
            updateData() // onDismiss
        } content: {
            SelectCalendarsView()
                .environmentObject(viewModel)
        }

        .sheet(isPresented: $showCreateEvent) {
            updateData() // onDismiss
        } content: {
            CreateOrEditEventView()
                .environmentObject(viewModel)
        }

        .sheet(item: $displayedEventDetails) {
            updateData() // onDismiss
        } content: { entity in
            EventDetailsView(entity: entity.entity)
                .environmentObject(viewModel)
        }
    }

    func updateData() {
        Task {
            await viewModel.fetch(displayMode.interval(selectedDate))
            updateID = UUID()
        }
    }

    // can't move this one to an extension, because _selectedDate is always private
    public func selectedDate(_ binding: Binding<Date>) -> CalendarView {
        var copy = self
        copy._selectedDate.bind(binding)
        return copy
    }
    
    public func needUpdate(_ binding: Binding<UUID>) -> CalendarView {
        var copy = self
        copy._needUpdate.bind(binding)
        return copy
    }

    public func displayMode(_ binding: Binding<CalendarDisplayMode>) -> CalendarView {
        var copy = self
        copy._displayMode.bind(binding)
        return copy
    }
}

public enum CalendarDisplayMode: Int,  Sendable {
    case day = 1
    case twoDays = 2
    case threeDays = 3
    case month = 30

    func interval(_ start: Date) -> DateInterval {
        let start = start.startOfDay
        return switch self {
        case .day:
            DateInterval(start: start, end: start.adding(.day, value: 1))
        case .twoDays:
            DateInterval(start: start, end: start.adding(.day, value: 2))
        case .threeDays:
            DateInterval(start: start, end: start.adding(.day, value: 3))
        case .month:
            DateInterval(start: start.startOfMonth, end: start.startOfMonth.adding(.month, value: 1))
        }
    }
}

struct CalendarEntityWrapper: Identifiable {
    let id: String
    let entity: any CalendarEntity

    init(_ entity: some CalendarEntity) {
        self.id = entity.id
        self.entity = entity
    }
}
