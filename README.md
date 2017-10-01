# XML Currency Parser

## Goals
1. UI screens with new `UIViewPropertyAnimator` (allows user to control animation).
2. Currency rate display
3. Currency converter
4. Currency rates updated every 30 seconds with `Timer`
5. Displaying active exchange rate

## Functions
1. Download XML data
2. Parse XML data into Object Structure
3. Give current rate for provided currency type
4. Display user balance for provided currency type
5. Update user balance in persistent way
6. Separate configuration file for setting URL and starting balance

## Unit Tests
1. Test currency list, all property should return correct count of currencies.
2. Test network API
3. Test currency converter