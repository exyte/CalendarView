//
//  CalendarView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 17.04.2025.
//

import SwiftUI
import AnchoredPopup

@MainActor
public struct CalendarView<DayEvent: View, MonthDay: View, WeekSwitcherDay: View, Header: View>: View {
    @State var viewModel: CalendarViewModel

    @ViewBuilder var dayEventBuilder: (any CalendarEntity) -> DayEvent
    @ViewBuilder var monthDayBuilder: (MonthDayBuilderParams) -> MonthDay
    @ViewBuilder var weekSwitcherDayBuilder: (WeekSwitcherDayBuilderParams) -> WeekSwitcherDay
    @ViewBuilder var headerBuilder: (HeaderBuilderParams) -> Header

    init(
        providers: [CalendarsProvider] = [],
        dayEventBuilder: @escaping (_ calendarEvent: any CalendarEntity) -> DayEvent,
        monthDayBuilder: @escaping (_ params: MonthDayBuilderParams) -> MonthDay,
        weekSwitcherDayBuilder: @escaping (WeekSwitcherDayBuilderParams) -> WeekSwitcherDay,
        headerBuilder: @escaping (_ params: HeaderBuilderParams) -> Header
    ) {
        self._viewModel = State(wrappedValue: CalendarViewModel(providers: providers))
        self.dayEventBuilder = dayEventBuilder
        self.monthDayBuilder = monthDayBuilder
        self.weekSwitcherDayBuilder = weekSwitcherDayBuilder
        self.headerBuilder = headerBuilder
    }

    @Environment(\.calendarTheme) var theme

    @BindableValue private var fullscreenDate: Date = Date().startOfDay
    @BindableValue private var displayMode: CalendarDisplayMode = .day

    @State private var anchorDate: Date = Date()
    @State private var showCalendarFilters = false
    @State private var showCreateEvent = false
    @State private var showEditEvent = false
    @State private var showEventDetails = false
    @State private var displayedEventDetails: CalendarEntityWrapper?

    @State private var isDaySwiping = false
    @State private var isCalendarScrolling = false
    @State private var currentPage: Int = 0

    // layout helpers
    @State private var hoursLabelsInset: CGFloat = 0

    @State private var hoursFittingCurrentZoom: CGFloat?
    @State private var currentZoom = 0.0
    @State private var pinchAnchor: CGFloat = 0.5

    var customizationParams = CalendarViewCustomizationParams()
    var idForUpdate: UUID = UUID()

    public var body: some View {
        VStack(spacing: 0) {
            headerBuilder(HeaderBuilderParams(
                fullscreenDate: $fullscreenDate,
                anchorDate: $anchorDate,
                displayMode: $displayMode,
                tapSelectDisplayModeClosure: {
                    AnchoredPopup.launchGrowingAnimation(id: "displayMode")
                },
                tapFilterCalendarsClosure: {
                    showCalendarFilters = true
                },
                tapAddEventClosure: {
                    showCreateEvent = true
                }
            ))
            .zIndex(1)

            if displayMode != .month {
                dayLayoutView
            } else {
                DayInMonthSwitcher(fullscreenDate: $fullscreenDate, calendarDisplayMode: $displayMode, monthDayBuilder: monthDayBuilder)
                    .padding(.top, 8)
                    .background(theme.month.background)
            }
        }
        .background(theme.main.background)
        .environment(viewModel)
        .environment(\.calendarCustomizationParams, customizationParams)
        .environment(\.hoursFittingCurrentZoom, hoursFittingCurrentZoom)
        .environment(\.showEventDetailsClosure) { (entity: any CalendarEntity) in
            if let eventDetailsClosure = customizationParams.eventDetailsClosure {
                eventDetailsClosure(entity)
            } else {
                displayedEventDetails = CalendarEntityWrapper(entity)
            }
        }
        .onChange(of: fullscreenDate, initial: true) {
            anchorDate = fullscreenDate
            updateData()
        }
        .onChange(of: displayMode) {
            updateData()
        }
        .onChange(of: idForUpdate) {
            updateData()
        }
        .onAppear {
            currentZoom = hoursFittingCurrentZoom ?? customizationParams.hoursToFit
        }

        .sheet(isPresented: $showCalendarFilters) {
            updateData() // onDismiss
        } content: {
            FilterCalendarsView()
                .environment(viewModel)
        }

        .sheet(isPresented: $showCreateEvent) {
            updateData() // onDismiss
        } content: {
            CreateEntityView(fullscreenDate: fullscreenDate) { entity in
                await viewModel.add(entity)
            }
            .environment(viewModel)
        }

        .fullScreenCover(item: $displayedEventDetails) {
            updateData() // onDismiss
        } content: { wrappedEntity in
            if let event = wrappedEntity.entity as? CalendarEvent {
                EntityDetailsView(entity: event)
                    .environment(viewModel)
            }
            if let reminder = wrappedEntity.entity as? CalendarReminder {
                EntityDetailsView(entity: reminder)
                    .environment(viewModel)
            }
        }
    }

    private var dayLayoutView: some View {
        GeometryReader { g in
            InfiniteTabPageView(
                currentPage: $currentPage,
                isDaySwiping: $isDaySwiping,
                isCalendarScrolling: isCalendarScrolling,
                width: g.size.width,
                didEndAnimation: { direction in
                    fullscreenDate = fullscreenDate.adding(.day, value: direction)
                }
            ) { page in
                Group {
                    let date = Calendar.current.date(byAdding: .day, value: page - currentPage, to: fullscreenDate) ?? fullscreenDate
                    DayLayout(
                        hoursLabelsInset: $hoursLabelsInset,
                        isCalendarScrolling: $isCalendarScrolling,
                        anchorDate: date,
                        daysCount: displayMode.rawValue,
                        events: viewModel.getEvents(from: date, displayMode: displayMode, fullscreenDate: fullscreenDate),
                        reminders: viewModel.getReminders(from: date, displayMode: displayMode, fullscreenDate: fullscreenDate),
                        isScrollDisabled: isDaySwiping,
                        pinchAnchor: pinchAnchor,
                        dayEventBuilder: dayEventBuilder
                    )
                    .background(theme.day.background)
                }
            }
            .simultaneousGesture(magnifyGesture)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        let h = max(1, g.size.height)
                        pinchAnchor = max(0, min(1, value.location.y / h))
                    }
            )
        }
    }

    private var magnifyGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                isDaySwiping = true
                let delta = (value.magnification - 1) * 3
                let desired = max(3.0, min(currentZoom - delta, 12.0))
                let current = hoursFittingCurrentZoom ?? customizationParams.hoursToFit
                if abs(desired - current) > 0.05 {
                    hoursFittingCurrentZoom = desired
                }
            }
            .onEnded { value in
                let delta = (value.magnification - 1) * 3
                currentZoom = max(3.0, min(currentZoom - delta, 12.0))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    isDaySwiping = false
                }
            }
    }

    func updateData() {
        Task {
            await viewModel.fetch(displayMode.interval(fullscreenDate))
        }
    }

    // can't move this one to an extension, because _fullscreenDate is always private
    public func fullscreenDate(_ binding: Binding<Date>) -> CalendarView {
        var copy = self
        copy._fullscreenDate.bind(binding)
        return copy
    }

    public func displayMode(_ binding: Binding<CalendarDisplayMode>) -> CalendarView {
        var copy = self
        copy._displayMode.bind(binding)
        return copy
    }
}

// a trick to be able to use an existential as fullScreenCover's item
struct CalendarEntityWrapper: Identifiable {
    let id: String
    let entity: any CalendarEntity

    init(_ entity: some CalendarEntity) {
        self.id = entity.id
        self.entity = entity
    }
}
