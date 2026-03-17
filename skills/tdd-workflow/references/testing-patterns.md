# TDD 참조 자료

## 테스트 유형별 가이드

### 단위 테스트 (Unit Test)
```
- 단일 함수/메서드 테스트
- 외부 의존성 모킹
- 빠른 실행 (< 100ms)
- 격리된 환경
```

### 통합 테스트 (Integration Test)
```
- 여러 컴포넌트 상호작용 테스트
- 실제 DB 또는 테스트 DB 사용
- API 엔드포인트 테스트
- 느린 실행 허용 (< 5s)
```

### E2E 테스트 (End-to-End Test)
```
- 전체 사용자 플로우 테스트
- 실제 환경과 유사한 설정
- 가장 느림 (< 30s)
- Critical Path만 테스트
```

## 테스트 커버리지 기준

### 유형별 비율
| 테스트 유형 | 비율 | 대상 |
|------------|------|------|
| Unit | 70-80% | 비즈니스 로직, 유틸리티 |
| Integration | 15-25% | API, DB 연동 |
| E2E | 5-10% | Critical User Journey |

### 커버리지 목표
```
최소 요구사항:
- Line Coverage: 80%+
- Branch Coverage: 75%+
- Function Coverage: 90%+

⚠️ 높은 커버리지 ≠ 좋은 테스트
의미 있는 assertion이 중요
```

### 커버리지 실행 명령어
```bash
# Python
pytest --cov=src --cov-report=term-missing --cov-fail-under=80

# JavaScript/TypeScript
npm test -- --coverage --coverageThreshold='{"global":{"lines":80}}'

# Java
mvn test jacoco:report
```

## 모킹 가이드

### 외부 서비스 모킹
```python
from unittest.mock import Mock, patch

def test_external_api_call():
    with patch('services.external_api.fetch') as mock_fetch:
        mock_fetch.return_value = {"status": "success"}
        result = my_service.process()
        assert result.status == "success"
        mock_fetch.assert_called_once()
```

### 데이터베이스 모킹
```python
@pytest.fixture
def mock_db():
    return Mock(spec=Database)

def test_user_repository(mock_db):
    mock_db.find_by_id.return_value = User(id=1, name="Test")
    repo = UserRepository(mock_db)
    user = repo.get(1)
    assert user.name == "Test"
```

## 테스트 작성 패턴

### Given-When-Then (BDD)
```python
def test_user_login():
    # Given: 유효한 사용자 자격 증명
    user = User(email="test@example.com", password="valid_password")
    
    # When: 로그인 시도
    result = auth_service.login(user.email, user.password)
    
    # Then: 로그인 성공
    assert result.success is True
    assert result.token is not None
```

### Arrange-Act-Assert (AAA)
```python
def test_calculate_total():
    # Arrange
    cart = ShoppingCart()
    cart.add_item(Item(price=100))
    cart.add_item(Item(price=200))
    
    # Act
    total = cart.calculate_total()
    
    # Assert
    assert total == 300
```
