<a href="https://exyte.com/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/exyte/media/master/common/header-dark.png"><img src="https://raw.githubusercontent.com/exyte/media/master/common/header-light.png"></picture></a>

<a href="https://exyte.com/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/exyte/media/master/common/our-site-dark.png" width="80" height="16"><img src="https://raw.githubusercontent.com/exyte/media/master/common/our-site-light.png" width="80" height="16"></picture></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="https://twitter.com/exyteHQ"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/exyte/media/master/common/twitter-dark.png" width="74" height="16"><img src="https://raw.githubusercontent.com/exyte/media/master/common/twitter-light.png" width="74" height="16">
</picture></a> <a href="https://exyte.com/contacts"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/exyte/media/master/common/get-in-touch-dark.png" width="128" height="24" align="right"><img src="https://raw.githubusercontent.com/exyte/media/master/common/get-in-touch-light.png" width="128" height="24" align="right"></picture></a>

![demo](https://user-images.githubusercontent.com/9447630/217482148-8594b3ce-e6be-4e84-a65d-29915566a61a.gif)

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
`selectedDate` - You can pass a binding to read/write currently selected date      
`displayMode` - You can pass a binding to read/write currently selected displayMode: `day`, `threeDays`, `month`    
`hoursToFit` - How many hours will fit vertically in a day displayMode    
`hourLabelFormat` - Hour format in a day displayMode    
`firstDayOfWeek` - What day to start a week from in all views, default is taken from current locale    
`headerBackground` - Background for header including week switcher: `none`, `color`, `view`      

### UI Customization
`dayEventBuilder` - in a .day `displayMode`, a rectangle view for one event. Has to have a greedy size to strech according to space available. Height available depends on event's duration and width on how many events there are in this day. So using `ViewThatFits` could be a good approach here. Also a good idea - applying `.clipped()` when even the smallest option doesn't fit, so the events don't intersect.     
`monthDayBuilder` - in a .month `displayMode`, a view to show for each day. It should be something like a month number with day's events list.   
`weekSwitcherDayBuilder` - in week picker in the header, a view for one day of week    
`headerBuilder` - this will be displayed above the week picker

```swift
CalendarView { calendarEvent in
    ZStack {
        Rectangle().foregroundStyle(.red.opacity(0.1))
        Text(calendarEvent.title)
    }
} monthDayBuilder: { params in
    Text(params.date.formatted(date: .abbreviated, time: .omitted))
} weekSwitcherDayBuilder: { params in
    Text(params.day.formatted("d.MM"))
        .foregroundStyle(params.isToday ? .blue : .black)
} headerBuilder: { params in
    HStack {
        Button("Show calendars") {
            params.tapFilterCalendarsClosure()
        }
        Button("Toggle mode") {
            params.displayMode.wrappedValue = params.displayMode.wrappedValue == .month ? .day : .month
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
