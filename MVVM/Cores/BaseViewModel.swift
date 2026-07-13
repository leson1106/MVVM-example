import RxSwift

protocol BaseViewModel {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}
