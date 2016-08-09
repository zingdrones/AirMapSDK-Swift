//
//  AirMapPermitQuestionViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift

class AirMapPermitQuestionViewController: UIViewController {
	
	var advisory: AirMapStatusAdvisory!
	var decisionFlow: AirMapPermitDecisionFlow!
	var question: AirMapAvailablePermitQuestion!
	
	@IBOutlet weak var questionLabel: UILabel!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var nextButton: UIButton!
	@IBOutlet weak var backButton: UIButton!
	
	private let selectedAnswer = Variable(nil as AirMapAvailablePermitAnswer?)
	private let selectedIndexPaths = Variable([NSIndexPath]())
	private let disposeBag = DisposeBag()
	
	private enum Segue: String {
		case PushNextQuestion  = "pushNextQuestion"
		case PushPermitMessage = "modalPermitMessage"
		case PushPermitDetail  = "pushPermitDetail"
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.estimatedRowHeight = 44
		tableView.rowHeight = UITableViewAutomaticDimension
		backButton.hidden = question == decisionFlow.questions.first
		navigationItem.title = advisory.name
		questionLabel.text = question.text

		setupBindings()
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		guard let identifier = segue.identifier else { return }
		
		switch Segue(rawValue: identifier)! {
			
		case .PushNextQuestion:
			
			guard let
				nextQuestionVC = segue.destinationViewController as? AirMapPermitQuestionViewController,
				selectedIndexPath = selectedIndexPaths.value.first,
				selectedAnswer = try? tableView.rx_modelAtIndexPath(selectedIndexPath) as AirMapAvailablePermitAnswer?,
				answer = selectedAnswer
				else { assertionFailure(); return }
			nextQuestionVC.advisory = advisory
			nextQuestionVC.question = nextQuestionFor(answer)
			nextQuestionVC.decisionFlow = decisionFlow
			
		case .PushPermitMessage:
			
			guard let
				nav = segue.destinationViewController as? UINavigationController,
				messageVC = nav.viewControllers.first as? AirMapPermitMessageViewController,
				selectedIndexPath = selectedIndexPaths.value.first,
				selectedAnswer = try? tableView.rx_modelAtIndexPath(selectedIndexPath) as AirMapAvailablePermitAnswer?,
				answer = selectedAnswer
				else { assertionFailure(); return }
			messageVC.message = answer.message
			
		case .PushPermitDetail:
			
			guard let
				permitDetailVC = segue.destinationViewController as? AirMapAvailablePermitViewController,
				selectedIndexPath = selectedIndexPaths.value.first,
				selectedAnswer = try? tableView.rx_modelAtIndexPath(selectedIndexPath) as AirMapAvailablePermitAnswer?,
				permitId = selectedAnswer?.permitId,
				permit = advisory.requirements!.permitsAvailable.filter({ $0.id == permitId }).first
				else { assertionFailure(); return }
			permitDetailVC.advisory = advisory
			permitDetailVC.permit = Variable(permit)
		}
		
	}

	@IBAction func unwindToQuestion(segue: UIStoryboardSegue) { /* Interface Builder hook; keep */ }

	private func setupBindings() {
		
		Observable
			.just(question.answers)
			.bindTo(tableView.rx_itemsWithCellIdentifier(String(AirMapPermitAnswerCell), cellType: AirMapPermitAnswerCell.self)) { row, answer, cell in
				cell.answer = Variable(answer)
			}
			.addDisposableTo(disposeBag)
		
		tableView
			.rx_itemSelected
			.map(tableView.rx_modelAtIndexPath)
			.bindTo(selectedAnswer)
			.addDisposableTo(disposeBag)
		
		tableView
			.rx_itemSelected
			.subscribeNext { [unowned self] indexPath in
				if !self.selectedIndexPaths.value.contains(indexPath) {
					self.selectedIndexPaths.value.append(indexPath)
				}
				self.tableView.cellForRowAtIndexPath(indexPath)?.selected = true
			}
			.addDisposableTo(disposeBag)
		
		tableView
			.rx_itemDeselected
			.subscribeNext { indexPath in
				self.selectedIndexPaths.value = self.selectedIndexPaths.value.filter { $0 != indexPath }
				self.tableView.cellForRowAtIndexPath(indexPath)?.selected = false
			}
			.addDisposableTo(disposeBag)
		
		selectedIndexPaths
			.asObservable()
			.map { $0.count == 1 }
			.bindTo(nextButton.rx_enabled)
			.addDisposableTo(disposeBag)
	}
	
	@IBAction func advance() {
		if selectedAnswer.value?.nextQuestionId != nil {
			performSegueWithIdentifier(Segue.PushNextQuestion.rawValue, sender: self)
		} else if selectedAnswer.value?.permitId != nil {
			performSegueWithIdentifier(Segue.PushPermitDetail.rawValue, sender: self)
		} else {
			performSegueWithIdentifier(Segue.PushPermitMessage.rawValue, sender: self)
		}
	}
	
	private func nextQuestionFor(answer: AirMapAvailablePermitAnswer) -> AirMapAvailablePermitQuestion? {
		guard let nextQuestionId = answer.nextQuestionId else { return nil }
		return decisionFlow.questions.filter { $0.id == nextQuestionId }.first
	}
	
}