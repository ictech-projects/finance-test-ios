# 05: Control Center "Add Expense" control

**What to build:** A user adds an "Add Expense" control to Control Center; tapping it opens (or completes) a quick-add expense flow.

**Blocked by:** 04 (Siri/Shortcuts quick-add expense) - done, [PR #25](https://github.com/ictech-projects/finance-test-ios/pull/25)

**Status:** In review

- [x] A Control Center control is available to add from the Controls gallery - `AddExpenseControl` in the new `finance-test-iosWidgets` extension. Verified on simulator: `chronod` registers `<CHSControlDescriptor: kind: com.indie.finance-test-ios.AddExpenseControl; action: appintent:OpenAddExpenseIntent; isLauncher: YES>` once the app has been installed and launched once. Adding it from the gallery by hand hasn't been done yet (see below).
- [x] Tapping the control invokes the same intent from #04 - **deviates, deliberately**: it runs `OpenAddExpenseIntent`, which opens the app on the same quick-add expense sheet, rather than `AddExpenseIntent` itself. A Control Center button cannot prompt for parameters, and `AddExpenseIntent` requires an amount and a category (required on purpose in #04 so Siri prompts for them), so running it from a control would fail on a missing amount every time. The control gives the user the flow; #04 stays the "no app needed" path.
- [x] The control has an appropriate icon/label reflecting its action - "Add Expense" with `creditcard.fill`, matching the "Log Expense" App Shortcut so both entry points read as the same action.

**Not verified by hand yet:** adding the control in Settings → Control Center (or the Lock Screen) and tapping it. The intent → UI hand-off is unit-tested (`OpenAddExpenseIntentTests`) and the system-side registration is confirmed in the log above, but Control Center taps aren't scriptable from the simulator.

**Notes for whoever picks up 02/03:**

- The widget extension target now exists (`finance-test-iosWidgets`, bundle id `com.indie.finance-test-ios.Widgets`), with `FinanceWidgetBundle` as its `@main`. Home Screen and Lock Screen widgets belong in that same bundle - no new target needed.
- The extension links **none** of the app's networking/repository code, which is why the control opens the app instead of writing a transaction itself. A widget that needs real data (ticket 02) has to solve that separately - either compile the data layer into the extension or share a snapshot through an App Group.
- `finance-test-iosShared/` is a third synchronized folder, compiled into both the app and the extension. Anything put there must stay Foundation-only.
- `AppIntentRouter` is the intent → UI hand-off. Deep links from a widget tap (ticket 02) or a Spotlight result (ticket 11) can add cases to its `Request` enum rather than inventing a second mechanism. `RootTabView` selects the tab; the destination screen consumes the request and calls `clear()`.
