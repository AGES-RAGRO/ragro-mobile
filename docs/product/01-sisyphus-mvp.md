# Sisyphus — Product MVP

Last updated: 2026-05-04

---

## 1. Product Vision

Sisyphus is a mobile app focused on turning long, emotionally heavy goals into small visible signs of progress. The product does not start from the logic of rigid productivity. It starts from progress awareness, self-compassion, and clarity.

### Value proposition

> Make visible the progress that is already happening, even when the user does not feel it.

### Core differentiation

- It is not just a task manager
- It does not measure personal worth through performance
- It uses narrative, visual feedback, and emotional state to support continuity
- It rewards consistency and clarity, not perfection

---

## 2. MVP Goal

Validate whether an experience built around micro-steps + emotional check-ins + progress visualization creates more:

- awareness of real progress
- continuity in long-term goals
- a sense of support on low-energy days
- recurring engagement without pressure

### What the MVP needs to prove

After one week of use, the user should feel:

- "I made progress"
- "I can see what I have done"
- "Even on difficult days, there was movement"

---

## 3. Initial Audience

### Primary profile

- people who start goals with strong energy but struggle to stay consistent
- people who feel frustrated by long-term goals
- users who do not connect with cold productivity apps
- users who value aesthetics, symbolism, and emotional feedback

### Jobs to be done

- "I want to stop feeling like I am going nowhere"
- "I want to break something big into smaller parts"
- "I want to see real progress without demanding perfection from myself"
- "I want to understand how my emotional state affects my pace"

---

## 4. Product Principles

- Small steps are the main unit of progress
- Emotional state influences the experience, not the user's value
- The app should support different kinds of days without punishment
- The journey should matter more than the summit
- Visual feedback should reinforce progress without feeling childish
- The product should reduce cognitive friction, not add complexity

---

## 5. Main MVP Flow

### 5.1 Onboarding

Goal: introduce the mountain metaphor and set up the first journey.

Steps:

1. Welcome screen with the Sisyphus metaphor and the idea of small steps
2. Selection of the first "mountain" or primary goal
3. Optional field: "Why does this matter to you?"
4. Guided breakdown of the goal into 3 to 7 initial small steps
5. First emotional check-in of the day
6. Entry into the main journey screen

### Rules

- onboarding should be short, ideally 3 to 5 minutes
- avoid long forms
- suggest ready-made examples of goals and micro-steps

### 5.2 Daily use

Goal: allow the user to see the journey, choose a small step, and register progress with low friction.

Steps:

1. The user opens the app and sees the current mountain
2. The app asks how they are arriving today
3. The user records their daily state
4. The user chooses a small step or creates a new one
5. The user completes the step
6. The environment visually reacts to progress
7. The app shows a short, supportive reinforcement

### 5.3 End of day

Goal: consolidate progress without requiring a long journal entry.

Steps:

1. The app shows how many steps were completed
2. It displays a short summary of the day
3. It offers an optional reflection
4. It saves the day's state in history

### 5.4 Weekly review

Goal: make accumulated progress visible.

Steps:

1. The app shows active days, completed steps, and mountain progress
2. It shows the relationship between emotional state and weekly pace
3. It reinforces consistency rather than perfection
4. It suggests an adjustment for the following week

---

## 6. Navigation Architecture

The MVP can operate with 4 main areas.

### 6.1 Journey

The app's main screen.

Content:

- mountain visual
- Sisyphus character
- current progress
- recommended step of the day
- CTA to complete or create a micro-step

### 6.2 Steps

Lightweight goal management area.

Content:

- list of micro-steps
- status: pending, in progress, completed
- simple step creation and editing
- grouping by goal

### 6.3 Reflections

Emotional history and perception area.

Content:

- past check-ins
- basic correlation between mood, energy, and completed steps
- daily and weekly summaries

### 6.4 Ritual

Reinforcement and pause area.

Content:

- celebrations
- light rewards
- pause moments
- continuity messages

---

## 7. Essential MVP Features

### 7.1 Primary goal

The user should be able to register one mountain at a time in the MVP.

Requirements:

- goal name
- optional description
- optional motivation
- ability to edit later

### 7.2 Breakdown into micro-steps

The app should help turn something large into small executable actions.

Requirements:

- create micro-steps manually
- example suggestions
- limit step complexity
- allow reorder

Functional best practices:

- each step should be concrete and observable
- steps should ideally fit into a few minutes or a short session
- the app should discourage vague tasks such as "fix my whole life"

### 7.3 Daily emotional check-in

The app needs to capture the day's context in a lightweight way.

Requirements:

- mood
- energy
- focus
- optional: short note or tag

Guideline:

- check-in in under 10 seconds
- no clinical language
- no judgment

### 7.4 Step completion with visual feedback

When a step is completed, the system must respond clearly.

Requirements:

- mark as completed
- move the trail or the stone forward
- change elements of the environment
- display a micro-reward in text or visuals

### 7.5 Progress screen

The user needs to see that progress is happening.

Requirements:

- percentage or progress milestone
- distance traveled in the journey
- steps completed this week
- streak of active days

### 7.6 Weekly summary

The MVP must generate clear reflection without becoming a complex report.

Requirements:

- total completed steps
- strongest weekly rhythm
- hardest days
- supportive closing message

---

## 8. Features Outside the MVP

These features are valuable, but should remain for later phases:

- multiple simultaneous mountains
- AI-assisted goal breakdown
- deep character customization
- social sharing
- dynamic soundscapes
- collectible systems
- full widget with statistics
- advanced behavioral insights
- community challenges

---

## 9. MVP Screens

### 9.1 Welcome

Goal:

- present the emotional promise of the app

Content:

- strong title
- short subtitle
- mountain illustration
- primary CTA

### 9.2 Create Mountain

Goal:

- define the core goal

Content:

- goal name
- why it matters
- CTA to continue

### 9.3 Break Into Steps

Goal:

- generate 3 to 7 micro-steps

Content:

- editable list
- example suggestions
- CTA to save journey

### 9.4 Daily Check-In

Goal:

- record emotional state

Content:

- simple selectors for mood, energy, and focus
- short optional field
- confirm CTA

### 9.5 Journey

Goal:

- be the center of the product

Content:

- mountain
- character
- daily and weekly progress
- recommended next step
- access to step completion

### 9.6 Steps List

Goal:

- provide practical control

Content:

- pending steps
- completed steps
- add step
- edit or remove

### 9.7 Daily Summary

Goal:

- consolidate the feeling of progress

Content:

- number of completed steps
- short message
- optional reflection

### 9.8 Weekly Summary

Goal:

- reinforce accumulated progress

Content:

- history
- emotional trend
- weekly highlight
- suggested adjustment

---

## 10. UX Rules for the Core Loop

- Every session should quickly lead the user to one small action
- The app should avoid too many fields, settings, and bureaucracy
- After every completion, the interface should respond in under 1 second
- The next recommended step should always be clear
- On low-energy days, the app should suggest smaller steps
- The product should validate rest and pause as part of the journey

---

## 11. Apple Native Design Best Practices

The app should feel like an authentic iOS product, not a generic ported interface.

### 11.1 Interface foundations

- use native components and Human Interface Guidelines conventions
- prioritize clarity, deference, and depth
- respect spacing, typographic hierarchy, and expected navigation behavior
- avoid excessive ornamentation in interactive elements
- use smooth animations with a functional purpose

### 11.2 Navigation

- use `Tab Bar` for main areas when there are 3 to 5 persistent destinations
- use `Navigation Stack` for deeper flow navigation
- keep titles clear and consistent
- avoid stacked modal flows
- use `Sheets` for short actions such as creating a step, check-ins, and quick reflections

### 11.3 Typography

- adopt `SF Pro` and system dynamic text styles
- use `Large Title` where appropriate at section entry points
- support `Dynamic Type`
- avoid overly small text in secondary components

### 11.4 Components and behavior

- primary buttons should have clear hierarchy across primary, secondary, and destructive actions
- toggles, pickers, and lists should behave natively
- cards can exist, but should not break touch, contrast, or readability conventions
- feedback should use smooth transitions, without overly loud celebration patterns

### 11.5 Motion and feel

- animations should communicate progress, continuity, and pause
- use `spring` and easing close to native iOS behavior
- respect `Reduce Motion`
- never rely only on animation to communicate information

### 11.6 Visual design

- use a clean, contemplative, and emotionally supportive visual base
- use depth with gradients, blur, and light in moderation
- avoid looking like a children's game
- maintain balance between poetic visuals and readability

---

## 12. Accessibility

Accessibility should not be treated as an extra layer. It is part of the product's human-centered promise.

### 12.1 Readability and contrast

- meet appropriate minimum contrast for text and controls
- do not depend on color as the only indicator of state
- ensure clear reading over illustrated scenes
- keep visual backgrounds controlled so they do not compete with content

### 12.2 Dynamic Type

- support large text scales without breaking layout
- avoid fixed heights in essential cards and buttons
- prioritize fluid layouts with vertical expansion

### 12.3 VoiceOver

- label all interactive elements clearly
- describe progress in objective language
- appropriate example: "Step 2 of 5 completed"
- hide purely decorative elements from the accessibility tree

### 12.4 Touch targets

- respect comfortable touch target sizes
- maintain enough spacing between nearby actions
- avoid tiny controls inside illustrations

### 12.5 Motion, haptics, and sensitivity

- provide a complete experience without depending on animation
- respect `Reduce Motion` and `Reduce Transparency`
- use haptics in moderation and always as optional reinforcement

### 12.6 Language

- use supportive, simple, and non-punitive language
- avoid terms such as "failed," "late," or "unproductive"
- prefer messages such as "today was a smaller step, but it was still a step"

### 12.7 Empty states and difficult days

- empty states should guide without blaming
- when there is no progress in a day, the interface should support the user and invite them to begin again
- the system should never induce shame for a broken streak

---

## 13. Conceptual MVP Data Model

### Goal

- id
- title
- purpose
- createdAt
- updatedAt
- status

### Step

- id
- goalId
- title
- note
- order
- status
- completedAt

### DailyCheckIn

- id
- date
- mood
- energy
- focus
- note

### WeeklySummary

- id
- weekStartDate
- totalCompletedSteps
- activeDays
- dominantMood
- reflection

---

## 14. Core Events to Measure the MVP

- onboarding_started
- onboarding_completed
- goal_created
- first_step_created
- checkin_completed
- step_completed
- weekly_summary_viewed
- return_next_day
- return_after_7_days

### Initial KPIs

- onboarding completion rate
- percentage of users who create at least 3 steps
- percentage of users who complete at least 1 step on day 1
- D1 and D7 retention
- average check-ins per week
- average completed steps per active user

---

## 15. Product Risks

- becoming only a to-do list with a beautiful skin
- overusing gamification and losing emotional credibility
- making check-ins feel tiring
- using too much illustration and hurting readability
- creating motivational copy that feels generic or artificial

### Mitigations

- keep the main loop simple
- test the real time needed to complete the main action
- validate microcopy with users
- prioritize functional clarity before expanding personalization

---

## 16. MVP Success Definition

The MVP will be successful if:

- the user can set up a first journey without high friction
- the app can turn one goal into clear small steps
- the user can perceive visual progress within a few minutes of use
- daily and weekly summaries reinforce continuity
- the experience remains supportive on low-energy days

---

## 17. Recommended Next Step

After this document, the ideal next step is to detail:

1. the full user flow with states and transitions
2. low-fidelity wireframes for the MVP screens
3. the initial iOS design system
4. a prioritized sprint backlog
