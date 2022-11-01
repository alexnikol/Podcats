// Copyright © 2022 Almost Engineer. All rights reserved.

import XCTest
import LoadResourcePresenter

class LoadResourcePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoading_displaysLoadingMessage() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoading()
        
        XCTAssertEqual(view.messages, [.display(isLoading: true)])
    }
    
    func test_didFinishLoadingWithError_stopsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didFinishLoading(with: anyNSError())
        
        XCTAssertEqual(view.messages, [.display(isLoading: false)])
    }
    
    func test_didFinishLoading_displaysResourceAndStopsLoading() {
        let (sut, view) = makeSUT { resource in
            return resource + " view model"
        }
        let resource = "any resource"
        
        sut.didFinishLoading(with: resource)
        
        XCTAssertEqual(view.messages, [
            .display(isLoading: false),
            .display(recource: resource + " view model")
        ])
    }
    
    func test_didFinishLoadingWithMapperError_stopsLoading() {
        let (sut, view) = makeSUT(mapper: { resource in
            throw anyNSError()
        })
        
        sut.didFinishLoading(with: "resource")
        
        XCTAssertEqual(view.messages, [
            .display(isLoading: false)
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = LoadResourcePresenter<String, ViewSpy>
    
    private func makeSUT(mapper: @escaping SUT.Mapper = { _ in "any" }, file: StaticString = #file, line: UInt = #line) -> (sut: SUT, view: ViewSpy) {
        let view = ViewSpy()
        let sut = SUT(resourceView: view, loadingView: view, mapper: mapper)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy: ResourceLoadingView, ResourceView {
        typealias ResourceViewModel = String
        
        enum Message: Hashable {
            case display(isLoading: Bool)
            case display(recource: String)
        }
        
        private(set) var messages: Set<Message> = []
        
        func display(_ viewModel: ResourceLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: ResourceViewModel) {
            messages.insert(.display(recource: viewModel))
        }
    }
}
