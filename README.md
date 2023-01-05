# 데브캘린더
<br />

[<img src = "https://devimages-cdn.apple.com/app-store/marketing/guidelines/images/badge-download-on-the-app-store.svg">](https://apps.apple.com/kr/app/데브캘린더/id1614854936)  

<p align="center">
  <a href="https://github.com/alexanderritik/Best-README-Template">
    <img src="https://user-images.githubusercontent.com/46002818/159280194-46412111-83d0-4fb2-8350-400ae9936c51.png" width="80" height="80">
  </a>
  <p align="center">
    🎉🎈 개발자 {웨비나, 컨퍼런스, 해커톤} 행사를 iOS 앱으로 알려드립니다.
  </p>
</p>

<p align="center">
<img src= "https://user-images.githubusercontent.com/46002818/159281005-6b71a5b2-fd46-4ea8-9482-36897653a084.png" width="200" >
<img src= "https://user-images.githubusercontent.com/46002818/159281021-db322ee0-439f-4e05-bbc9-6d4218b0cf44.png" width="200" >
<img src = "https://user-images.githubusercontent.com/46002818/159281027-e135668a-f5e9-40d9-927d-214c4ebc0d04.png" width ="200">
</p>

<br/>
<br/>

## ⚙️ 개발 환경
- Language: Swift 5.5.2
- iOS Deployment Target: iOS 13.0 +
- Xcode: 13.0 compatible

<br/>

## 👩‍💻 기술 스택
- CocoaPods
- CoreData
- MVVM
- RxSwift
- Unit Test

<br/>

## 📚 사용 라이브러리 
### CocoaPods
- [RxCocoa](https://github.com/ReactiveX/RxSwift)
- [RxDataSources](https://github.com/RxSwiftCommunity/RxDataSources)
- [RxGesture](https://github.com/RxSwiftCommunity/RxGesture)
- [RxSwift](https://github.com/ReactiveX/RxSwift)
- [SwiftSoup](https://github.com/scinfu/SwiftSoup)
- [Toaster](https://github.com/devxoul/Toaster#appearance)
   
<br/>

## 🛠 프로젝트 구조
### 1. Coordinator 패턴
<p align="center">
<img width="740" alt="스크린샷 2023-01-02 오후 7 42 15" src="https://user-images.githubusercontent.com/46002818/210220949-744068bf-ff73-4d7b-be1d-e152454087d8.png">
</p>

- 네모 상자로 표현된 coordinator은 protocol Coordinator을 준수합니다
- View Controller는 일대일로 매칭되는 coordinator가 있으며 뷰 전환의 일을 coordinator에게 전담해 로직을 분리시켰습니다   
  
    #### ✅ Coordinator 패턴 도입의 효과
    현재 프로젝트에서는 뷰 전환 시나리오가 단순합니다. 뷰 전환이 복잡하고 다양한 시나리오에서 사용한다면 View Controller에서 뷰 전환 로직을 따로 분리해주기 때문에 도입 가치가 높을 것이라 생각합니다. 학습에 의의를 두고 사용하였습니다.

<br/>

### 2. MVVM 패턴과 Input/Output 바인딩
<p align="center">
<img width="740" alt="스크린샷 2023-01-02 오후 9 22 48" src="https://user-images.githubusercontent.com/46002818/210230709-4449a52f-5c5a-4148-a065-b698c2da1952.png">
</p>

- View Controller는 View를 소유하고 있으며 둘은 긴밀하게 엮여있습니다
- View Controller는 ViewModel을 소유하며 둘은 Input과 Output을 통해 소통합니다
- View Controller는 ViewModel의 input을 통해 데이터를 가져오는 액션을 요구하고 ViewModel은 Output을 통해 Model에서 가져온 데이터를 가공하여 전달합니다
- ViewModel의 Input과 Output은 struct 형태입니다. ViewModel의 데이터 관련 프로퍼티들은 모두 private으로 설정되어 있습니다. View Controller에서는 함수 *transform(input:)* 을 통해 output을 얻어 사용할 수 있습니다.   
  
    #### ✅ Input, Output 도입 이유
    Intput, Output을 도입하기 이전에는 ViewModel의 프로퍼티들이 public으로 공개되어 있어 View Controller가 임의로 접근이 가능해 데이터 변질 우려가 있었습니다. 이 부분을 고민하다가 Input/Output 구조를 많이 이용하는 것을 알게 되었고 적용하였습니다. 그 결과, ViewModel의 프로퍼티들은 private하게 설정되어 데이터의 안정성을 보장할 수 있었고, 더불어 함수 *transform(input:)* 를 통해 로직의 분리시켜 데이터 흐름을 파악하기 쉬워졌습니다. (ViewModel에서 뿐만 아니라 RxSwift를 이용하여 바인딩되는 코드에서는 Input/Output을 사용하였습니다)
```swift
//  HomeViewController.swift

final class HomeViewModel: ViewModelType {
    struct Input {
        var requestFetchingEvents: Observable<Void>
    }
    
    struct Output {
        var dataSources: Observable<[SectionOfEvents]>
        var isNetworkConnect: Observable<Bool>
    }

    private let eventsFromServer: BehaviorRelay<[SectionOfEvents]> = BehaviorRelay(value: [])
    private let favoriteEvents: BehaviorRelay<[EventCoreData]> = BehaviorRelay(value: [])
    
    func transform(input: Input) -> Output {
        ...
        return Output(dataSources: ..., isNetworkConnect: ...)
    }
}
```
```swift
//  HomeViewModel.swift

final class HomeViewController: UIViewController {
    let viewModel = HomeViewModel()

    func bindViewModel() {
        let input = HomeViewModel.Input(requestFetchingEvents: requestFetchingEvents.asObservable())
        let output = viewModel.transform(input: input)
        ...
    }
}
```

<br/>

### 3. 비즈니스 로직
<p align="center">
<img width="787" alt="image" src="https://user-images.githubusercontent.com/46002818/210701586-1744fb27-1d41-4031-a422-fe41d79c1169.png">
</p>  

- NetworkService를 통해 서버에서 html 정보를 가져옵니다
- DevEventsFetcher에서 가져온 String 값인 html을 파싱하여 데이터를 가공합니다
- DevEventsFetcher는 싱글톤 객체이므로 데이터가 업데이트 될 때마다 이를 구독하고 있는 모든 ViewModel들에게 알려줍니다  
- CoreData에서 데이터를 가져오고 저장하는 PersistanceManager를 싱글턴 객체로 두어 관리합니다
    
    #### ✅ NetworkService 객체  
    개발 초기에는 싱글턴으로 구현했다가 유닛 테스트를 도입하며 DevEventsFetcher에서 객체를 생성할 수 있도록 변경하였습니다. 프로젝트에서 네트워크를 담당하는 것은 NetworkService 클래스 하나로 관리하기 쉽게 하기 위하여 싱글턴으로 설계하였으나, 현재 DevEventsFetcher에서만 네트워크 통신이 일어나며 유닛테스트 때 mockURLSession을 만드는데 어려움이 있었습니다. 유닛테스트를 도입하면서 싱글턴이 아닌 단순 클래스로 변경하였습니다.


<br/>


### 4. 네트워크 연결 관리
싱글턴 클래스인 NetworkConnectionManager를 두어 사용자의 기기가 네트워크에 연결되어있는지 감시하는 역할을 합니다. 앱이 실행될 때 자동으로 모니터링이 실행되며, ViewModel들이 네트워크 연결 여부를 구독하고 있어 상황에 맞게 처리해줍니다.



<br/>

## ♻️ 업데이트
- **v1.0.4** iOS16에서 발생하는 버그 개선
- **v1.0.3** 즐겨찾기한 이벤트 목록에서 종료된 이벤트 section 추가
- **v1.0.2** 별 모양 이미지 중앙정렬 및 리팩터링
- **v1.0.1** 다크모드 디자인 개선 및 리팩터링
- **v1.0** 앱 스토어 출시 (22.04.11)

<br/>


## ✉️  문의사항
jinhyang.programmer@gmail.com
