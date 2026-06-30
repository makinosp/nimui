# Execution Plan — NimUI State Management (Cycle 2)

## Goal
Implement a reactive state management system where UI components automatically update when their bound state changes, targeting the Nim JS backend.

## Phase 1: Runtime Infrastructure (JS/Nim JS)
The foundation for reactivity must be established in the runtime to handle state tracking and DOM updates.

### 1.1 State Wrapper Implementation
- Create a `State[T]` type in Nim.
- Ensure it compiles to a JavaScript object that holds the value and a list of subscribers (callbacks).
- Implement a `.value` property with a getter and setter. The setter must trigger all subscribers.

### 1.2 DOM Update Registry
- Implement a global registry (in JS) that maps `StateID` $\rightarrow$ `seq[DOMElementID]`.
- Create a `updateElement(elementId, newValue)` function that updates the `innerText` or `value` of a specific DOM element.

### 1.3 Binding Logic
- Implement a `bindState(stateId, elementId, updateFn)` function to be called during initial page load to link a state variable to a DOM element.

## Phase 2: Macro System Extension
The macros must be updated to automate the binding process.

### 2.1 State Detection
- Update the `ui` and component macros to detect when a `State` object is passed as an argument (e.g., to `Text`).

### 2.2 ID Generation
- Generate unique IDs for any DOM element that is bound to a `State` variable.
- Ensure these IDs are consistent between the HTML generation and the JS binding code.

### 2.3 Binding Code Injection
- Modify the macro expansion to inject the necessary `bindState` calls into the final generated JavaScript.
- Example: `Text(myState)` $\rightarrow$ `<span id="id1">...</span>` + `bindState("state_id", "id1", ...)`

## Phase 3: Verification & Testing
Ensure the system works as expected and doesn't introduce regressions.

### 3.1 Unit Tests
- Test `State[T]` value updates and subscriber notifications.
- Test the DOM update registry in a simulated browser environment (if possible) or via integration tests.

### 3.2 Integration Example (The Counter)
- Create `examples/counter.nim`:
    - Define `let count = State(0)`.
    - Create a `VStack` with a `Text` showing `count` and a `Button` that increments `count`.
- Verify that clicking the button updates the text without a page reload.

## Success Criteria
- [ ] `State[T]` can be defined and mutated.
- [ ] UI components bound to `State` update automatically upon mutation.
- [ ] No full-page re-renders occur during state updates.
- [ ] The DSL remains clean and idiomatic.
