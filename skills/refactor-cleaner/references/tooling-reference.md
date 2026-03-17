# 리팩토링 도구 및 스크립트 레퍼런스

## 도구별 분석 명령어

### Python
```bash
# 사용하지 않는 임포트 확인
autoflake --check --remove-all-unused-imports -r .

# 사용하지 않는 변수 확인
pylint --disable=all --enable=unused-variable .

# 데드 코드 분석
vulture . --min-confidence 80
```

### JavaScript/TypeScript
```bash
# ESLint로 미사용 변수 확인
eslint --rule 'no-unused-vars: error' .

# 미사용 exports 확인
npx ts-prune

# 미사용 의존성 확인
npx depcheck
```

### Java
```bash
# 미사용 임포트 확인
mvn spotless:check

# 데드 코드 분석
mvn pmd:check
```

## 자동 정리 스크립트

### Python
```bash
# 미사용 임포트 자동 제거
autoflake --in-place --remove-all-unused-imports -r src/

# isort로 임포트 정리
isort src/
```

### JavaScript/TypeScript
```bash
# ESLint 자동 수정
eslint --fix .

# 미사용 import 제거
npx eslint --fix --rule 'unused-imports/no-unused-imports: error' .
```

## 정리 대상 코드 패턴

### 1. 사용하지 않는 임포트
```python
# Before
import os
import sys  # 사용 안 함
from typing import List, Dict, Optional  # Dict 사용 안 함

# After
import os
from typing import List, Optional
```

### 2. 사용하지 않는 변수
```python
# Before
def process(data):
    unused_var = "never used"  # 삭제 대상
    result = transform(data)
    return result

# After
def process(data):
    result = transform(data)
    return result
```

### 3. 도달 불가능 코드
```python
# Before
def example():
    return "result"
    print("이 코드는 실행되지 않음")  # 삭제 대상

# After
def example():
    return "result"
```

## 삭제하면 안 되는 경우

### 1. 의도적 미사용
```python
# 의도적으로 미사용 (인터페이스 준수)
def callback(event, context):  # context는 AWS Lambda 규약
    return handle(event)
```

### 2. 미래 사용 예정 (주석 처리된 코드)
### 3. 동적 로딩 (\_\_import\_\_ 등)
### 4. 테스트 전용 헬퍼

## 문서 템플릿

### 리팩토링 리포트 저장 위치
```
{project}/docs/refactoring/YYYY-MM-DD-<target>-refactor.md
```

### 리포트 구조
```markdown
# Refactoring Report: <Target Name>

## Overview
- **Date**: YYYY-MM-DD
- **Target**: <리팩토링 대상 경로>

## Summary
| 항목 | 수치 |
|------|------|
| 분석된 파일 | N개 |
| 발견된 이슈 | N개 |
| 삭제된 코드 | N개 |
| 검토 필요 | N개 |

## 삭제된 항목 🔴
| 파일 | 라인 | 타입 | 코드 |

## 검토 필요 항목 🟡
| 파일 | 라인 | 타입 | 이유 |

## 유지된 항목 🟢
| 파일 | 라인 | 타입 | 유지 이유 |

## 테스트 결과
## 후속 작업
## 변경된 파일 목록
```
