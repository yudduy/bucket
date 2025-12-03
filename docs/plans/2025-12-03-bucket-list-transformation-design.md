# Bucket List App Transformation Design

**Date:** 2025-12-03
**Status:** Ready for Implementation

---

## Overview

Transform the Threads clone into a Bucket List social app for goal tracking. Users add bucket list items (goals) and post progress updates as they work toward them. The feed shows friends' ongoing journeys, focusing on the process rather than completion.

---

## Core Concept

**Goal Tracking** - Users add bucket list items and post frequent progress updates:
- "Learn Spanish" → posts daily Duolingo screenshots
- "Get fit" → posts gym selfies
- "Read 50 books" → posts book covers as they finish

The accountability mechanism: friends like your progress, you get dopamine to keep going.

---

## Data Model

### Goal (NEW)

```swift
Goal {
  id: String (UUID)
  userId: String (owner)
  title: String (required)
  description: String? (optional)
  category: String? (optional - "Learning", "Fitness", "Travel", "Creative", "Career", "Health")
  createdAt: Date
  updateCount: Int (denormalized for display)
}
```

### ProgressUpdate (replaces Thread)

```swift
ProgressUpdate {
  id: String (UUID)
  goalId: String (parent goal reference)
  userId: String (author)
  content: String (update text)
  imageUrl: String? (optional photo)
  createdAt: Date
  likes: Int
  likedBy: [String] (user IDs)
}
```

### Firestore Collections

- `goals` - stores Goal documents (NEW)
- `progress_updates` - stores ProgressUpdate documents (replaces `threads`)
- `threads_users` - unchanged
- `threads_notifications` - unchanged (update message copy only)

### Atomic Operations

When creating a ProgressUpdate:
1. Create ProgressUpdate document
2. Increment Goal.updateCount using `FieldValue.increment(1)`
3. Both in a single Firestore batch/transaction

---

## Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Feed content | Progress updates only | Journey focus; updates are the social content |
| Goal structure | Title + optional description/category | Low friction to start; add context if wanted |
| Profile view | Goal cards (grouped) | Easy to browse "What is Sarah working on?" |
| Engagement | Likes only (skip comments MVP) | Simplifies launch; add comments later |
| Explore tab | Keep as-is | Category discovery is post-MVP |
| Notifications | Keep follow + like | Accountability loop via like notifications |
| Goal lifecycle | No archive/complete | Goals exist indefinitely; delete if needed |
| Feed tap behavior | Navigate to GoalDetailView | Shows full journey context |

---

## UI Flows

### Tab Structure (unchanged)

```
Tab 0: Feed → Shows ProgressUpdates from followed users
Tab 1: Explore → User suggestions (unchanged)
Tab 2: Create → Goal picker (changed - see below)
Tab 3: Activity → Notifications (update copy only)
Tab 4: Profile → Goal cards (changed - see below)
```

### Create Flow (changed)

```
Tap "+" → Goal Picker Sheet
  ├── "Create New Goal" button → CreateGoalView
  │     └── Title field (required)
  │     └── Description field (optional)
  │     └── Category pills (optional)
  │     └── "Create" → saves Goal, returns to picker
  │
  └── List of user's existing Goals
        └── Tap a Goal → CreateProgressUpdateView
              └── Content field
              └── Add photo button
              └── "Post" → saves ProgressUpdate, increments updateCount
```

### Profile Flow (changed)

```
User info (unchanged)
  ↓
Grid/List of GoalCards (sorted by most recently updated)
  └── Each card shows: title, category tag, updateCount, last update thumbnail
  └── Tap card → GoalDetailView
        └── Goal header (title, description, category)
        └── List of ProgressUpdateCells (chronological)
        └── Like buttons on each update
```

### Feed Flow (minimal change)

```
ProgressUpdateCell shows:
  └── User avatar + username + timestamp
  └── "Updated 'Goal Title'" subtitle (NEW - links to parent goal)
  └── Content text
  └── Optional image
  └── Like button (heart icon)
  └── REMOVED: Comment button, Repost button

Tap zones:
  └── Tap user avatar → ProfileView
  └── Tap anywhere else → GoalDetailView (parent goal with all updates)
```

---

## Architecture Changes

### Files to RENAME (17 files)

#### Models
- `ThreadBO.swift` → `ProgressUpdateBO.swift`
- `CreateThreadBO.swift` → `CreateProgressUpdateBO.swift`

#### DTOs
- `ThreadDTO.swift` → `ProgressUpdateDTO.swift`
- `CreateThreadDTO.swift` → `CreateProgressUpdateDTO.swift`
- `CreateThreadDTO+Dictionary.swift` → `CreateProgressUpdateDTO+Dictionary.swift`

#### DataSources
- `ThreadsDataSource.swift` → `ProgressUpdateDataSource.swift`
- `FirestoreThreadsDataSourceImpl.swift` → `FirestoreProgressUpdateDataSourceImpl.swift`

#### Mappers
- `ThreadMapper.swift` → `ProgressUpdateMapper.swift`
- `CreateThreadMapper.swift` → `CreateProgressUpdateMapper.swift`

#### Repositories
- `ThreadsRepository.swift` → `ProgressUpdateRepository.swift`
- `ThreadsRepositoryImpl.swift` → `ProgressUpdateRepositoryImpl.swift`

#### UseCases
- `FetchThreadsUseCase.swift` → `FetchFeedUpdatesUseCase.swift`
- `CreateThreadUseCase.swift` → `CreateProgressUpdateUseCase.swift`
- `LikeThreadUseCase.swift` → `LikeProgressUpdateUseCase.swift`

#### ViewModels
- `BaseThreadsActionsViewModel.swift` → `BaseProgressUpdateActionsViewModel.swift`
- `CreateThreadViewModel.swift` → `CreateProgressUpdateViewModel.swift`
- `UserContentListViewModel.swift` → `UserGoalsListViewModel.swift`

#### Views
- `ThreadCell.swift` → `ProgressUpdateCell.swift`
- `CreateThreadView.swift` → `CreateProgressUpdateView.swift`
- `UserContentListView.swift` → `UserGoalsListView.swift`

### Files to ADD (16 files)

#### Goal Models
- `GoalBO.swift`
- `CreateGoalBO.swift`

#### Goal DTOs
- `GoalDTO.swift`
- `CreateGoalDTO.swift`
- `CreateGoalDTO+Dictionary.swift`

#### Goal DataSource
- `GoalDataSource.swift`
- `FirestoreGoalDataSourceImpl.swift`

#### Goal Mapper
- `GoalMapper.swift`

#### Goal Repository
- `GoalRepository.swift`
- `GoalRepositoryImpl.swift`

#### Goal UseCases
- `CreateGoalUseCase.swift`
- `FetchUserGoalsUseCase.swift`
- `DeleteGoalUseCase.swift`
- `FetchProgressUpdatesByGoalUseCase.swift`

#### Goal ViewModels
- `CreateGoalViewModel.swift`
- `GoalDetailViewModel.swift` (extends BaseProgressUpdateActionsViewModel)

#### Goal Views
- `CreateGoalView.swift`
- `GoalCard.swift`
- `GoalDetailView.swift`
- `GoalPickerSheet.swift`

### Files to REMOVE (4 files)

- `FetchOwnThreadsUseCase.swift` (replaced by goal-based queries)
- `FetchThreadsByUserUseCase.swift` (replaced by goal-based queries)
- `ProfileThreadFilter.swift` (no filter tabs needed)
- Reply/comment UI elements from cells

### Files to UPDATE

#### DI Container (Container.swift)

```swift
// RENAME (Thread → ProgressUpdate)
var progressUpdateMapper: Factory<ProgressUpdateMapper>
var progressUpdateDataSource: Factory<ProgressUpdateDataSource>
var progressUpdateRepository: Factory<ProgressUpdateRepository>
var fetchFeedUpdatesUseCase: Factory<FetchFeedUpdatesUseCase>
var createProgressUpdateUseCase: Factory<CreateProgressUpdateUseCase>
var likeProgressUpdateUseCase: Factory<LikeProgressUpdateUseCase>
var fetchProgressUpdatesByGoalUseCase: Factory<FetchProgressUpdatesByGoalUseCase>

// ADD (Goal infrastructure)
var goalMapper: Factory<GoalMapper>
var goalDataSource: Factory<GoalDataSource>
var goalRepository: Factory<GoalRepository>
var createGoalUseCase: Factory<CreateGoalUseCase>
var fetchUserGoalsUseCase: Factory<FetchUserGoalsUseCase>
var deleteGoalUseCase: Factory<DeleteGoalUseCase>

// REMOVE
var fetchOwnThreadsUseCase  // deleted
var fetchThreadsByUserUseCase  // deleted
```

#### ViewModel Updates

**BaseProgressUpdateActionsViewModel** (renamed from BaseThreadsActionsViewModel):
- `@Injected var likeThreadUseCase` → `likeProgressUpdateUseCase`
- `threads: [ThreadBO]` → `progressUpdates: [ProgressUpdateBO]`

**FeedViewModel** (extends BaseProgressUpdateActionsViewModel):
- `@Injected var fetchThreadsUseCase` → `fetchFeedUpdatesUseCase`

**UserGoalsListViewModel** (renamed from UserContentListViewModel):
- `@Injected var fetchThreadsByUserUseCase` → `fetchUserGoalsUseCase`
- `threads: [ThreadBO]` → `goals: [GoalBO]`

---

## UI String Changes

| Location | Current | New |
|----------|---------|-----|
| CreateGoalView nav title | - | "Add Goal" |
| CreateProgressUpdateView nav title | "New Thread" | "Post Update" |
| CreateProgressUpdateView button | "Post" | "Post" (keep) |
| CreateGoalView placeholder | - | "What's on your bucket list?" |
| CreateProgressUpdateView placeholder | "Start a thread ..." | "Share your progress..." |
| FeedView nav title | "Threads" | "Bucket List" |
| ProfileView empty state | "This user has no posts yet." | "No goals yet" |
| Share content | "Check out this thread:" | "Check out this progress update:" |
| Notification copy | "liked your thread" | "liked your progress update" |

---

## What Stays Unchanged

- All UI styling, colors, fonts, spacing
- Firebase Auth setup and configuration
- Image upload functionality (Storage)
- Like mechanics (just renamed)
- Share functionality
- Follow/unfollow system
- User model and profile editing
- Notifications infrastructure (just update copy)
- MVVM + Clean Architecture patterns
- DI pattern (Views own ViewModels, ViewModels inject UseCases)

---

## Out of Scope (MVP)

- Comments/replies on progress updates
- Goal archive/complete states with celebration UI
- Category-based discovery in Explore tab
- Following individual goals (only follow users)
- Metrics, deadlines, or counters on goals
- "Paused" vs "active" goal states
- Search/filter in goal picker
- Pinned/favorite goals

---

## Implementation Order

1. **Phase 1: Data Layer** - Models, DTOs, Mappers (rename + add Goal)
2. **Phase 2: DataSources** - Firestore implementations (rename + add Goal)
3. **Phase 3: Repositories** - Business logic layer (rename + add Goal)
4. **Phase 4: UseCases** - Application logic (rename + add new)
5. **Phase 5: ViewModels** - State management (rename + add new)
6. **Phase 6: Views** - UI components (rename + add new + update existing)
7. **Phase 7: DI Container** - Wire everything together
8. **Phase 8: UI Strings** - Update copy throughout
9. **Phase 9: Cleanup** - Remove dead code, test build

---

## Validation Checklist

- [ ] Can create a new Goal with title
- [ ] Can create a Goal with optional description and category
- [ ] Can post a ProgressUpdate to an existing Goal
- [ ] Feed shows ProgressUpdates from followed users
- [ ] Feed items show parent Goal context
- [ ] Tapping feed item navigates to GoalDetailView
- [ ] Profile shows GoalCards (not flat updates)
- [ ] Tapping GoalCard shows all updates for that goal
- [ ] Like button works on ProgressUpdates
- [ ] Goal.updateCount increments when posting update
- [ ] Notifications work for follows and likes
- [ ] Can delete a Goal (cascades to updates)
- [ ] Empty states display correctly
