<a href="https://exyte.com/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/exyte/media/master/common/header-dark.png"><img src="https://raw.githubusercontent.com/exyte/media/master/common/header-light.png"></picture></a>

<a href="https://exyte.com/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/exyte/media/master/common/our-site-dark.png" width="80" height="16"><img src="https://raw.githubusercontent.com/exyte/media/master/common/our-site-light.png" width="80" height="16"></picture></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="https://twitter.com/exyteHQ"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/exyte/media/master/common/twitter-dark.png" width="74" height="16"><img src="https://raw.githubusercontent.com/exyte/media/master/common/twitter-light.png" width="74" height="16">
</picture></a> <a href="https://exyte.com/contacts"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/exyte/media/master/common/get-in-touch-dark.png" width="128" height="24" align="right"><img src="https://raw.githubusercontent.com/exyte/media/master/common/get-in-touch-light.png" width="128" height="24" align="right"></picture></a>

<img width="200" src="https://github.com/user-attachments/assets/0a710d26-8d1f-4c02-aafe-cd06d0e3e7a2" />
<img width="200" src="https://github.com/user-attachments/assets/37e41800-6e57-4067-85e7-99ee677efde9" />
<img width="200" src="https://github.com/user-attachments/assets/4a5718d8-eb7c-4ba7-a227-645c1ca15795" />
<img width="200" src="https://github.com/user-attachments/assets/f04a5b6a-566b-4703-bc9b-6c1ab1010252" />

<p><h1 align="left">Calendar View</h1></p>

<p><h4>CalendarView is a library to display events in day/month modes</h4></p>

![](https://img.shields.io/github/v/tag/exyte/CalendarView?label=Version)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fexyte%2FCalendarView%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/exyte/CalendarView)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fexyte%2FCalendarView%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/exyte/CalendarView)
[![SPM](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swiftpackageindex.com/exyte/CalendarView)
[![License: MIT](https://img.shields.io/badge/License-MIT-black.svg)](https://opensource.org/licenses/MIT)

# Usage 
```swift
import CalendarView

CalendarView()
```

### Available customizations - modifiers
`fullscreenDate` - You can pass a binding to read/write the currently displayed date      
`displayMode` - You can pass a binding to read/write the current display mode: `day`, `twoDays`, `threeDays`, `month`    
`hoursToFit` - How many hours will fit vertically in day display modes, default is 12    
`hourLabelFormat` - Hour label format in day display modes, default is `"h a"`    
`firstDayOfWeek` - What day to start a week from in all views, default is taken from current locale    
`headerBackground` - Background for the header: `.none`, `.color(Color, cornerRadius)`, or `.view(AnyView)`. Use the `headerBackground(viewBuilder:)` overload to pass a SwiftUI view directly.    
`isDayInWeekSwitcherPagingEnabled` - Swipe just one week at a time or several at once in the week switcher     
`eventDetailsClosure` - Closure called when the user taps an event, receives the tapped entity    
`idForUpdate` - Pass a new UUID value to trigger a calendar data refresh    
`customFont` - Use a custom font family by name. All font sizes and colors defined in the library are preserved. Weight variants are determined by the font itself.    
`useDynamicType` - When `true`, all font sizes scale with the system-wide Dynamic Type accessibility setting (Settings → Accessibility → Display & Text Size → Larger Text)

### UI Customization - builders
`dayEventBuilder` - In day display modes, a view for one event. Must have a greedy size to stretch according to available space. Height depends on event duration, width on how many events overlap. `ViewThatFits` is a good approach here. Also consider applying `.clipped()` so short events don't overflow into neighboring slots.     
`monthDayBuilder` - In `.month` mode, a view for each day cell. `MonthDayBuilderParams` provides `date`, `events`, and `viewHeight`.   
`weekSwitcherDayBuilder` - A view for one day in the default header's week picker. `WeekSwitcherDayBuilderParams` provides `day`, `monthDisplayMode`, and `fullscreenDate`. When using a fully custom `headerBuilder`, embed the week picker via `params.defaultWeekSwitcher(weekSwitcherDayBuilder:)` instead — see below.    
`headerBuilder` - Replaces the entire header area. `HeaderBuilderParams` provides:
  - `fullscreenDate`, `anchorDate`, `displayMode` — bindings to read/write calendar state
  - `tapFilterCalendarsClosure`, `tapAddEventClosure`, `tapSelectDisplayModeClosure` — actions to trigger built-in sheets
  - `defaultWeekSwitcher()` — renders the built-in week picker with default day cells
  - `defaultWeekSwitcher(weekSwitcherDayBuilder:)` — renders the built-in week picker with a custom day cell view

### Events
If you want to implement your own event manager for complete event control:
You can create your own `CalendarProvider` and pass it a `CalendarView(providers: [...Your provider...])`.
In a custom provider, you need to override the `getEvents` method, in which you will independently pass the necessary events. 
You also need to override the `getCalendars` method and always return at least one element.
```
override func getCalendars() async throws -> [ProviderCalendar] {
    [ ProviderCalendar() ]
}
```

### Hints & Tips
If, when you first load the application, events are displayed only after the current day changes, set the value for `fullscreenDate`:
```
@State private var fullscreenDate = Date().startOfDay
```

```swift
CalendarView(providers: CalendarDefaults.defaultProviders) { entity in
    ZStack {
        Rectangle().foregroundStyle(.red.opacity(0.1))
        Text(entity.title)
    }
} monthDayBuilder: { params in
    Text(params.date.formatted(date: .abbreviated, time: .omitted))
} headerBuilder: { params in
    VStack {
        HStack {
            Button("Calendars") {
                params.tapFilterCalendarsClosure()
            }
            Button("Add event") {
                params.tapAddEventClosure()
            }
            Button(params.displayMode.wrappedValue.title) {
                params.displayMode.wrappedValue = params.displayMode.wrappedValue == .month ? .day : .month
            }
        }
        params.defaultWeekSwitcher { weekParams in
            Text(weekParams.day.formatted("d.MM"))
                .foregroundStyle(weekParams.day == Date().startOfDay ? .blue : .black)
        }
    }
}
```

## Examples

To try the CalendarView examples:
- Clone the repo `https://github.com/exyte/CalendarView.git`
- Open `CalendarViewExample.xcodeproj` in the Xcode
- Try it!

## Installation

### [Swift Package Manager](https://swift.org/package-manager/)

```swift
dependencies: [
    .package(url: "https://github.com/exyte/CalendarView.git")
]
```

## Requirements

* iOS 17+
* Xcode 16+ 

## Our other open source SwiftUI libraries
[PopupView](https://github.com/exyte/PopupView) - Toasts and popups library   
[AnchoredPopup](https://github.com/exyte/AnchoredPopup) - Anchored Popup grows "out" of a trigger view (similar to Hero animation)    
[Grid](https://github.com/exyte/Grid) - The most powerful Grid container    
[ScalingHeaderScrollView](https://github.com/exyte/ScalingHeaderScrollView) - A scroll view with a sticky header which shrinks as you scroll   
[AnimatedTabBar](https://github.com/exyte/AnimatedTabBar) - A tabbar with a number of preset animations    
[MediaPicker](https://github.com/exyte/mediapicker) - Customizable media picker     
[Chat](https://github.com/exyte/chat) - Chat UI framework with fully customizable message cells, input view, and a built-in media picker  
[OpenAI](https://github.com/exyte/OpenAI) Wrapper lib for [OpenAI REST API](https://platform.openai.com/docs/api-reference/introduction)    
[AnimatedGradient](https://github.com/exyte/AnimatedGradient) - Animated linear gradient     
[ConcentricOnboarding](https://github.com/exyte/ConcentricOnboarding) - Animated onboarding flow    
[FloatingButton](https://github.com/exyte/FloatingButton) - Floating button menu    
[ActivityIndicatorView](https://github.com/exyte/ActivityIndicatorView) - A number of animated loading indicators    
[ProgressIndicatorView](https://github.com/exyte/ProgressIndicatorView) - A number of animated progress indicators    
[FlagAndCountryCode](https://github.com/exyte/FlagAndCountryCode) - Phone codes and flags for every country    
[SVGView](https://github.com/exyte/SVGView) - SVG parser    
[LiquidSwipe](https://github.com/exyte/LiquidSwipe) - Liquid navigation animation    
