[Читать на русском](./README.ru.md)

# Habit Tracking Mobile App — Technical Specification

## Links

- [Figma Design](https://www.figma.com/design/owAO4CAPTJdpM1BZU5JHv7/Tracker)

## Purpose and Goals

The application helps users build and maintain healthy habits by tracking their completion over time.

Main goals:

- Track habits on selected days of the week  
- View habit progress and performance  

## App Overview

- The app consists of tracker cards created by the user. Each card can have a name, category, schedule, emoji, and color to distinguish it.
- Cards are grouped by categories. Users can search and filter them.
- A calendar view allows users to see planned habits for a specific date.
- A statistics section displays progress, success rates, and average metrics.

## Functional Requirements

### Onboarding

When the app is launched for the first time, users are guided through an onboarding flow.

The onboarding screen includes:

1. Splash screen  
2. Title and subtitle  
3. Page indicators  
4. A call-to-action button: “Awesome tech!”

User actions and behavior:

- Users swipe left and right to navigate between pages; the page indicators update accordingly.  
- Tapping the button takes the user to the main screen.

### Creating a Habit Tracker Card

On the main screen, the user can create a tracker for either a recurring habit or a one-off event.

- **Habits** are recurring events with a set schedule.  
- **Irregular events** are not tied to specific days.

#### Habit Tracker Creation Screen

1. Screen title  
2. Tracker name input field  
3. Category section  
4. Schedule settings  
5. Emoji picker  
6. Color picker  
7. Cancel button  
8. Create button  

#### Irregular Event Creation Screen

Identical, but without the schedule section.

#### Behavior

- **Tracker name**  
  - After typing one character, a clear icon appears.  
  - Maximum length: 38 characters. If exceeded, a validation error message is displayed beneath the field.  
- **Category**  
  - Opens a selection screen. A placeholder is shown if no categories exist.  
  - The last selected category is marked with a checkmark.  
  - Users can add a new category:  
    - The Done button is disabled until at least one character is typed.  
    - After saving, the new category appears unchecked in the list.  
- **Schedule** (habits only)  
  - Users toggle days of the week.  
  - A summary shows the chosen days; if all are selected, it shows “Every day”.  
- **Emoji and color** can be chosen to personalize the tracker.  
- **Create** becomes active only when all required fields are filled.  
- After creation, the tracker appears in the appropriate category on the main screen.

### Main Screen

The main screen lets users view trackers for the selected date, mark habits as done, and access statistics.

Main screen elements:

1. “+” button to add a habit or event  
2. Title: “Trackers”  
3. Current date selector  
4. Search input  
5. Tracker cards grouped by category:  
   - Emoji  
   - Tracker name  
   - Count of completed days  
   - Button to mark as done  
6. Filter button  
7. Tab bar  

Functionality:

- “+” opens a bottom sheet for creating a habit or event.  
- Tapping the date opens a calendar; users navigate months and pick a day to view that day’s trackers.  
- Search filters trackers by name; an empty state appears if nothing matches.  
- **Filters** (bottom sheet, hidden if no trackers for the selected date):  
  - “All trackers” — shows every tracker for the date.  
  - “Today’s trackers” — sets the date selector to today and shows all scheduled trackers.  
  - “Completed” — shows trackers completed on the date.  
  - “Uncompleted” — shows trackers not completed on the date.  
- Vertical scrolling displays the list; if images are loading, a system loader is shown.  
- Tapping a card opens a modal:  
  - **Pin/unpin** — pinned trackers appear under a “Pinned” category at the top; unpinning removes them from this section.  
  - **Edit** — opens a modal identical to the creation screen.  
  - **Delete** — action sheet for confirmation; confirmed deletion removes all associated data.  
- The tab bar switches between **Trackers** and **Statistics**.

### Editing and Deleting Categories

Categories can be managed during tracker creation.

Behavior:

- Long-pressing a category opens a modal:  
  - **Edit** — rename the category, then save.  
  - **Delete** — confirmation sheet; on approval, the category and its data are removed.

### Statistics Screen

Users can review performance metrics over time.

Statistics screen includes:

1. Title: “Statistics”  
2. List of metrics, each showing:  
   - Numeric value  
   - Metric title  
3. Tab bar  

Metrics:

- **Best Streak** — longest run of consecutive days without missing habits  
- **Perfect Days** — days when all scheduled habits were completed  
- **Trackers Completed** — total number of completed habits  
- **Average** — average number of habits completed per day  

Behavior:

- If no data exists, an empty state is shown.  
- Metrics without data display zero.  
- Statistics appear once at least one metric has data.

### Dark Mode

The app supports dark mode and automatically adapts to the device’s system theme.

## Non-Functional Requirements

1. Supports iPhone X and newer and is optimized for iPhone SE.  
2. Minimum iOS version: 13.4.  
3. Uses the default iOS system font — SF Pro.  
4. Core Data is used for persistent habit storage.
