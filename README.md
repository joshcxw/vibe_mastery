# Dolch Sight Word Match

## Overview

Dolch Sight Word Match is a child-friendly Flutter mobile app designed to help early readers (ages 4–8) practice Dolch sight words through a concentration-style memory game. Players choose one of the five required Dolch sight-word levels, match identical word pairs, receive a score at the end of each round, and can review their score history and statistics. The app works completely offline and is intended for a single user.

This project was developed as an individual assignment for **CPSC 4150/6150 – Mobile Device Software Development**.

---

# Implemented Game

**Word Match**

Players flip over cards to find matching pairs of identical Dolch sight words.

Features include:

* Five Dolch word levels

  * Pre-Primer
  * Primer
  * First Grade
  * Second Grade
  * Third Grade
* Six matching pairs per round
* Randomized cards each game
* End-of-round score
* Local score history
* Statistics screen
* Fully offline gameplay

---

# Scoring Model

Each completed Word Match round produces a score from **0–100**.

A perfect round earns **100** by finding every pair on the first attempt.

Additional unsuccessful pair attempts reduce the score. Time is recorded for statistics but does not affect the score in the current version.

The combined score shown on the Statistics screen is the **average score across all completed rounds**, with every completed round weighted equally.

---

# Architecture Overview

The project separates responsibilities into small components:

* **Dolch data layer** — built-in word lists organized by level
* **Game logic** — pure Dart matching controller
* **Scoring** — pure Dart scoring model
* **Persistence** — local storage for completed rounds
* **Statistics** — aggregation logic independent of Flutter widgets
* **UI** — Flutter screens and reusable widgets

Keeping the matching and scoring logic independent from Flutter makes those components easier to unit test.

---

# How to Run

## Prerequisites

Install:

* Flutter SDK
* Dart SDK (included with Flutter)

Verify Flutter is installed:

```bash
flutter doctor
```

Resolve any reported issues before running the project.

## Install dependencies

From the project directory:

```bash
flutter pub get
```

## Run the application

Launch on an emulator or connected device:

```bash
flutter run
```

## Run all tests

```bash
flutter test
```

---

# Tradeoff Decisions

## Tradeoff 1 – Word Storage

I chose **Dart constants** over **JSON assets** because the Dolch word lists are fixed, relatively small, and built into the application. This keeps the implementation simple and avoids runtime asset loading.

The cost of this approach is that updating the word lists requires recompiling the application.

This will hold up until the application needs downloadable or user-editable word lists.

---

## Tradeoff 2 – Scoring Model

I chose a **normalized 0–100 efficiency score** over raw flip counts because it is easier for children, parents, and teachers to understand and allows future game types to share a common scoring scale.

The cost of this approach is that elapsed time does not currently affect the score.

This will hold up until additional games require a more sophisticated scoring model.

---

## Tradeoff 3 – Architecture

I chose a **small feature-based architecture with pure Dart game logic** over a larger enterprise architecture because this is a single-game student project.

The cost of this approach is that it has fewer extension points than a larger architecture.

This will hold up until the project grows into multiple complex games or requires online synchronization.

---

# AI Usage

This project was developed using AI assistance as required by the course assignment. AI was used to help plan the architecture, generate implementation checkpoints, explain code, assist with debugging, and create tests. All design decisions, integration, testing, and final understanding remained my responsibility.
Link to full ChatGPT Prompt Log:
https://chatgpt.com/share/6a544a73-ff30-83ea-9c17-0709560d900a

---

# Original Work Statement

This application is distinct from both my Solo 3 project and my team project, as required by the assignment.

---

# Future Improvements

Possible future enhancements include:

* Additional Dolch practice games
* Sound effects
* Optional text-to-speech
* Achievement badges
* Difficulty settings
* Animated card flips
* Accessibility improvements
* Additional statistics and progress tracking
