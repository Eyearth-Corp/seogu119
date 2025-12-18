/**
 * Tizen OS 호환성 및 최적화 스크립트
 * 서구 골목경제 119 상황판용 타이젠 최적화
 */

// 타이젠 환경 감지
function isTizenDevice() {
    return (
        typeof tizen !== 'undefined' || 
        navigator.userAgent.includes('Tizen') ||
        navigator.userAgent.includes('SMART-TV')
    );
}

// 타이젠 TV용 최적화
function optimizeForTizen() {
    if (isTizenDevice()) {
        console.log('타이젠 환경 감지됨 - 최적화 적용');

        // TV 리모컨 키 이벤트 처리
        document.addEventListener('keydown', handleTizenKeyEvent);

        // 터치 이벤트 최적화
        initTouchSupport();

        // 메모리 최적화
        if (window.gc && typeof window.gc === 'function') {
            setInterval(() => {
                window.gc();
            }, 30000); // 30초마다 가비지 컬렉션
        }

        // 성능 모니터링
        if (performance && performance.memory) {
            setInterval(logMemoryUsage, 60000); // 1분마다 메모리 사용량 로그
        }
    }
}

// 타이젠 TV 리모컨 키 이벤트 처리
function handleTizenKeyEvent(event) {
    const keyCode = event.keyCode;
    
    switch(keyCode) {
        case 37: // 왼쪽 화살표
            console.log('Left arrow pressed');
            break;
        case 38: // 위쪽 화살표
            console.log('Up arrow pressed');
            break;
        case 39: // 오른쪽 화살표
            console.log('Right arrow pressed');
            break;
        case 40: // 아래쪽 화살표
            console.log('Down arrow pressed');
            break;
        case 13: // Enter/확인
            console.log('Enter pressed');
            break;
        case 10009: // 뒤로가기
            console.log('Back pressed');
            break;
    }
}

// 메모리 사용량 로깅
function logMemoryUsage() {
    if (performance.memory) {
        const memInfo = {
            used: Math.round(performance.memory.usedJSHeapSize / 1048576) + 'MB',
            total: Math.round(performance.memory.totalJSHeapSize / 1048576) + 'MB',
            limit: Math.round(performance.memory.jsHeapSizeLimit / 1048576) + 'MB'
        };
        console.log('메모리 사용량:', memInfo);
    }
}

// 타이젠 앱 생명주기 이벤트
if (typeof tizen !== 'undefined') {
    try {
        tizen.application.getCurrentApplication().addEventListener('lowbattery', function() {
            console.log('배터리 부족 - 성능 절약 모드 활성화');
            // 성능 절약 로직 추가 가능
        });
        
        tizen.application.getCurrentApplication().addEventListener('suspend', function() {
            console.log('앱 일시정지');
        });
        
        tizen.application.getCurrentApplication().addEventListener('resume', function() {
            console.log('앱 재개');
        });
    } catch (e) {
        console.log('타이젠 API 접근 실패:', e);
    }
}

// 화면 크기 최적화 (타이젠 TV용)
function optimizeScreenSize() {
    if (isTizenDevice()) {
        const viewport = document.querySelector('meta[name="viewport"]');
        if (viewport) {
            // TV 해상도에 맞춰 뷰포트 조정
            viewport.setAttribute('content', 'width=1920, height=1080, user-scalable=no');
        }
    }
}

// DOM 로드 완료 시 초기화
document.addEventListener('DOMContentLoaded', function() {
    optimizeForTizen();
    optimizeScreenSize();
});

// Flutter 앱 로드 완료 시 추가 최적화
window.addEventListener('flutter-first-frame', function() {
    if (isTizenDevice()) {
        console.log('Flutter 첫 프레임 렌더링 완료 - 타이젠 최적화 적용');
        
        // 차트 애니메이션 최적화 (타이젠에서는 부드러운 애니메이션을 위해)
        const style = document.createElement('style');
        style.textContent = `
            .fl-chart-line {
                will-change: transform;
                transform: translateZ(0);
            }
            * {
                -webkit-font-smoothing: antialiased;
                -moz-osx-font-smoothing: grayscale;
            }
        `;
        document.head.appendChild(style);
    }
});

// ============================================
// 터치 이벤트 지원 (대형 터치 TV용)
// ============================================

// 터치 지원 초기화
function initTouchSupport() {
    console.log('터치 지원 초기화');

    // 터치 이벤트 리스너 등록
    document.addEventListener('touchstart', handleTouchStart, { passive: false });
    document.addEventListener('touchmove', handleTouchMove, { passive: false });
    document.addEventListener('touchend', handleTouchEnd, { passive: false });
    document.addEventListener('touchcancel', handleTouchCancel, { passive: false });

    // 터치 피드백 스타일 추가
    addTouchFeedbackStyles();

    // 터치 영역 최적화
    optimizeTouchTargets();

    console.log('터치 지원 초기화 완료');
}

// 터치 상태 관리
let touchState = {
    startX: 0,
    startY: 0,
    startTime: 0,
    isScrolling: false,
    activeElement: null
};

// 터치 시작 처리
function handleTouchStart(event) {
    const touch = event.touches[0];
    touchState.startX = touch.clientX;
    touchState.startY = touch.clientY;
    touchState.startTime = Date.now();
    touchState.isScrolling = false;

    // 터치된 요소에 시각적 피드백
    const target = event.target;
    if (target && target.classList) {
        target.classList.add('touch-active');
        touchState.activeElement = target;
    }

    console.log('터치 시작:', { x: touch.clientX, y: touch.clientY });
}

// 터치 이동 처리
function handleTouchMove(event) {
    if (!touchState.startTime) return;

    const touch = event.touches[0];
    const deltaX = touch.clientX - touchState.startX;
    const deltaY = touch.clientY - touchState.startY;

    // 스크롤 감지 (10px 이상 이동 시)
    if (Math.abs(deltaX) > 10 || Math.abs(deltaY) > 10) {
        touchState.isScrolling = true;
        // 터치 피드백 제거
        if (touchState.activeElement) {
            touchState.activeElement.classList.remove('touch-active');
        }
    }
}

// 터치 종료 처리
function handleTouchEnd(event) {
    const touchDuration = Date.now() - touchState.startTime;

    // 터치 피드백 제거
    if (touchState.activeElement) {
        touchState.activeElement.classList.remove('touch-active');
        touchState.activeElement = null;
    }

    // 탭 감지 (300ms 이하, 스크롤 아님)
    if (touchDuration < 300 && !touchState.isScrolling) {
        console.log('탭 감지');
    }

    // 롱프레스 감지 (500ms 이상)
    if (touchDuration >= 500 && !touchState.isScrolling) {
        console.log('롱프레스 감지');
    }

    // 상태 초기화
    touchState.startTime = 0;
    touchState.isScrolling = false;
}

// 터치 취소 처리
function handleTouchCancel(event) {
    if (touchState.activeElement) {
        touchState.activeElement.classList.remove('touch-active');
        touchState.activeElement = null;
    }
    touchState.startTime = 0;
    touchState.isScrolling = false;
    console.log('터치 취소');
}

// 터치 피드백 스타일 추가
function addTouchFeedbackStyles() {
    const style = document.createElement('style');
    style.textContent = `
        /* 터치 피드백 효과 */
        .touch-active {
            opacity: 0.7 !important;
            transform: scale(0.98) !important;
            transition: opacity 0.1s, transform 0.1s !important;
        }

        /* 터치 영역 최적화 - 최소 48px */
        button, a, [role="button"], .clickable, .touchable {
            min-width: 48px !important;
            min-height: 48px !important;
            touch-action: manipulation;
        }

        /* 터치 하이라이트 제거 */
        * {
            -webkit-tap-highlight-color: transparent;
            -webkit-touch-callout: none;
            -webkit-user-select: none;
            user-select: none;
        }

        /* 스크롤 최적화 */
        .scrollable {
            -webkit-overflow-scrolling: touch;
            overflow-scrolling: touch;
        }

        /* 대형 터치 TV용 버튼 크기 확대 */
        @media (min-width: 1920px) {
            button, [role="button"] {
                min-width: 64px !important;
                min-height: 64px !important;
                font-size: 18px !important;
            }
        }
    `;
    document.head.appendChild(style);
    console.log('터치 피드백 스타일 적용');
}

// 터치 영역 최적화
function optimizeTouchTargets() {
    // Flutter 캔버스가 로드된 후 실행
    setTimeout(() => {
        const canvas = document.querySelector('canvas');
        if (canvas) {
            // 캔버스 터치 이벤트 최적화
            canvas.style.touchAction = 'none';
            console.log('캔버스 터치 최적화 적용');
        }
    }, 2000);
}

// 멀티터치 지원 (핀치 줌 등)
let pinchState = {
    initialDistance: 0,
    currentScale: 1
};

function getDistance(touch1, touch2) {
    const dx = touch1.clientX - touch2.clientX;
    const dy = touch1.clientY - touch2.clientY;
    return Math.sqrt(dx * dx + dy * dy);
}

// 멀티터치 감지
document.addEventListener('touchstart', function(event) {
    if (event.touches.length === 2) {
        pinchState.initialDistance = getDistance(event.touches[0], event.touches[1]);
        console.log('핀치 제스처 시작');
    }
}, { passive: true });

document.addEventListener('touchmove', function(event) {
    if (event.touches.length === 2 && pinchState.initialDistance > 0) {
        const currentDistance = getDistance(event.touches[0], event.touches[1]);
        const scale = currentDistance / pinchState.initialDistance;
        console.log('핀치 스케일:', scale.toFixed(2));
        // 여기서 줌 기능 구현 가능
    }
}, { passive: true });

document.addEventListener('touchend', function(event) {
    if (event.touches.length < 2) {
        pinchState.initialDistance = 0;
    }
}, { passive: true });

console.log('타이젠 최적화 스크립트 로드 완료');