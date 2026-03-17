# Complexity Analysis Reference

## Signs of Excessive Complexity

- **Unnecessary abstraction**: Interfaces/abstract classes used only once
- **Design pattern overuse**: Factory, Strategy, Decorator for simple problems
- **Deep inheritance hierarchy**: More than 3 levels
- **Excessive generics**: Complex type parameters hard to read
- **Premature Optimization**: Complex optimizations without actual bottlenecks
- **Over-engineering**: Excessively extensible design beyond current requirements

## Complexity Check Questions

1. **"Can a junior developer understand this in 30 minutes?"**
2. "Can the same functionality be implemented with half the code?"
3. "Is this abstraction actually reused, or was it created 'just in case'?"
4. "What problem occurs if we remove the design pattern? Can you explain specifically?"
5. "Was Strategy pattern used when if-else would suffice?"
6. "Is this the simplest solution for current requirements?"

## Complexity Metrics

| Metric | Recommended | Warning | Dangerous |
|--------|-------------|---------|-----------|
| Cyclomatic Complexity | ≤10 | 11-20 | >20 |
| Nesting Depth | ≤3 | 4 | ≥5 |
| Function Parameters | ≤4 | 5-6 | ≥7 |
| Class Dependencies | ≤5 | 6-8 | ≥9 |
| Inheritance Depth | ≤2 | 3 | ≥4 |

## Simplification Suggestions

- Factory → Simple constructor or static method
- Strategy → if-else or switch
- Abstract class (single implementation) → Concrete class
- Multiple wrapper classes → Direct invocation
- Complex generics → Concrete types

## Karpathy Guidelines (변경 범위 검증)

### 외과적 변경 원칙

- [ ] **범위 한정**: 모든 변경 라인이 요청 사항과 직접 연결되는가?
- [ ] **인접 코드 보존**: 요청과 무관한 코드/주석/포맷팅을 "개선"하지 않았는가?
- [ ] **기존 스타일 유지**: 다르게 하고 싶어도 기존 컨벤션을 따랐는가?
- [ ] **데드코드 처리**: 기존 데드코드는 언급만, 이번 변경으로 생긴 고아 코드만 정리했는가?

### 목표 검증 가능성

- [ ] 성공 기준이 명확하고 검증 가능한가?
- [ ] "버그 수정" → 재현 테스트가 있는가?
- [ ] "기능 추가" → 해당 기능 테스트가 있는가?

### 가정 명시 여부

- [ ] 암묵적 가정이 코드나 주석에 명시되어 있는가?
- [ ] 불명확한 부분에 대해 질문했거나 문서화했는가?
