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

console.log('타이젠 최적화 스크립트 로드 완료');