# Enehid

## Table of Contents

1. [Overview](#overview)
2. [Product Spec](#product-spec)
3. [Wireframes](#wireframes)
4. [Schema](#schema)
5. [Demo](#demo)

## Overview

### Description

**Enehid** ("እንሒድ" in Amharic, meaning "Let's go") is a mobile-first event coordination app that enables friends to collaboratively plan hangouts. It integrates real-time event creation, in-app group messaging, expense tracking, and venue discovery using Google Places API. The app uses Firebase for backend infrastructure including authentication, data storage, and media management.

## Demo

https://github.com/user-attachments/assets/3b6a48f0-326b-4029-8347-8d506311c135

## App Evaluation

* **Category:** Social / Productivity
* **Mobile:** iOS-first, leveraging SwiftUI and Firebase SDKs
* **Story:** Helps friend groups plan, coordinate, and manage events with ease
* **Market:** College students, young professionals, and social friend groups
* **Habit:** Moderate to frequent usage depending on event frequency
* **Scope:** Core feature set includes event creation, group chat, expenses, and venue search

## Product Spec

### 1. User Stories (Completed/Planned)
* [x] User can sign up and log in with Firebase Auth
* [x] User can create an event with a title, date, and description
* [x] User can join existing events by invitation code
* [x] User can participate in a dedicated event chat
* [x] User can add expenses to an event and track group balances
* [x] User can search and attach a location to an event using Google Places

## Wireframes

## Schema

### Models

#### User

| Property     | Type     | Description          |
| ------------ | -------- | -------------------- |
| id           | String   | Firebase UID         |
| email        | String   | Unique email address |
| name         | String   | Display name         |
| joinedEvents | [String] | List of Event IDs    |

#### Event

| Property | Type     | Description                          |
| -------- | -------- | ------------------------------------ |
| id       | String   | Unique identifier                    |
| title    | String   | Event name                           |
| date     | DateTime | Scheduled time of event              |
| location | String   | Google Place ID or formatted address |
| members  | [String] | UIDs of users attending              |

#### Message

| Property  | Type     | Description                |
| --------- | -------- | -------------------------- |
| id        | String   | Unique ID for each message |
| senderId  | String   | UID of message sender      |
| content   | String   | Message body               |
| timestamp | DateTime | Time sent                  |
| eventId   | String   | Associated event           |

#### Expense

| Property     | Type     | Description                           |
| ------------ | -------- | ------------------------------------- |
| id           | String   | Expense ID                            |
| title        | String   | Expense name                          |
| amount       | Float    | Expense cost                          |
| paidBy       | String   | UID of person who paid                |
| splitBetween | [String] | UIDs of participants sharing the cost |

### Networking

All requests are handled via Firebase SDKs:

* `FirebaseAuth` for login/register
* `Firestore` for fetching, listening to, and updating event, message, and expense data
* `FirebaseStorage` (planned use for uploading media/chat images)
* `Google Places API` for venue search and selection

## License

This repository is licensed under the **MIT License**.

```
MIT License

Copyright (c) 2025 Edom Belayneh

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```


