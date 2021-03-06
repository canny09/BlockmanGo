//
//  LoginViewController.swift
//  BlockmanGo
//
//  Created by KiBen on 2018/8/23.
//  Copyright © 2018年 SanboxOL. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate: class {
    func loginViewControllerDidCancel(_ viewController: LoginViewController)
    func loginViewControllerDidLoginSuccessful(_ viewController: LoginViewController)
}

/// parameter为(Bool, LoginViewControllerDelegate)元组值，第一个参数 是否为验证失败需要重新登录；第二个参数是传代理对象
class LoginViewController: UIViewController {

    weak var delegate: LoginViewControllerDelegate?
    
    private enum SignPlatform: Int {
        case facebook
        case twitter
        case google
        
        var toSignInPlatform: SignInPlatformEnum {
            switch self {
            case .facebook:
                return SignInPlatformEnum.facebook
            case .twitter:
                return SignInPlatformEnum.twitter
            case .google:
                return SignInPlatformEnum.google
            }
        }
    }
    
    private weak var accountTextField: UITextField?
    private weak var passwordTextField: UITextField?
    private weak var registerButton: UIButton?
    private weak var mailButton: UIButton?
    private weak var loginButton: UIButton?
    private weak var twitterButton: AdjustLayoutButton?
    private weak var facebookButton: AdjustLayoutButton?
    private weak var googleButton: AdjustLayoutButton?
    
    private var isAuthorizationExpired = false
    private let googleSignInService = GoogleSignService()
    private var facebookSignInService: FacebookSignService?
    
    deinit {
        DebugLog("LoginViewController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        googleSignInService.delegate = self
        googleSignInService.uiDelegate = self
        facebookSignInService = FacebookSignService(from: self)
        facebookSignInService?.delegate = self
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        if let (isExpired, loginControllerDelegate) = parameter as? (Bool, LoginViewControllerDelegate?) {
            isAuthorizationExpired = isExpired
            delegate = loginControllerDelegate
        }
        
        let containView = UIImageView(image: R.image.general_alert_background()).addTo(superView: view).configure { (imageView) in
            imageView.isUserInteractionEnabled = true
        }.layout { (make) in
            make.width.equalTo(310)
            make.center.equalToSuperview()
        }
        
        var topLabel = UILabel()
        if isAuthorizationExpired { // 验证失效，重新登录
            topLabel = ExtraSizeLabel().addTo(superView: containView).configure { (label) in
                label.backgroundColor = R.clr.appColor._ed8b74()
                label.textColor = UIColor.white
                label.font = UIFont.size12
                label.text = R.string.localizable.authorization_expired_then_resign()
                label.layer.cornerRadius = 12
                label.clipsToBounds = true
                label.contentInset = UIEdgeInsetsMake(0, 10, 0, 0)
            }.layout { (make) in
                make.left.right.top.equalToSuperview().inset(20)
                make.height.equalTo(30)
            }
        }else { // 切换账号
            topLabel = UILabel().addTo(superView: containView).configure { (label) in
                label.textColor = R.clr.appColor._844501()
                label.font = UIFont.size13
                label.text = R.string.localizable.current_ID() + "\(UserManager.shared.userID)"
            }.layout { (make) in
                make.left.top.equalToSuperview().offset(20)
            }
        }
        
        let shadowContainView = UIView().addTo(superView: containView).configure { (view) in
            view.backgroundColor = R.clr.appColor._eed5a0()
            view.layer.cornerRadius = 12
        }.layout { (make) in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(topLabel.snp.bottom).offset(isAuthorizationExpired ? 12 : 5)
            make.height.equalTo(192)
        }
        
        accountTextField = CommonTextField(placeHolder: R.string.localizable.input_account_and_id()).addTo(superView: shadowContainView).layout(snapKitMaker: { (make) in
            make.left.right.top.equalToSuperview().inset(10)
            make.height.equalTo(40)
        }).configure({ (textField) in
            textField.text = UserManager.shared.account.isEmpty ? "\(UserManager.shared.userID)" : UserManager.shared.account
        })
        
        passwordTextField = CommonTextField(placeHolder: R.string.localizable.input_password()).addTo(superView: shadowContainView).configure({ (textfield) in
            textfield.isSecureTextEntry = true
        }).layout(snapKitMaker: { (make) in
            make.top.equalTo(accountTextField!.snp.bottom).offset(5)
            make.size.centerX.equalTo(accountTextField!)
        })
        
        let buttonConfig = {(button: UIButton) in
            button.backgroundColor = R.clr.appColor._94d559()
            button.layer.cornerRadius = 8
            button.titleLabel?.font = UIFont.size11
            button.setTitleColor(UIColor.white, for: .normal)
        }
        registerButton = UIButton().addTo(superView: shadowContainView).configure(buttonConfig).configure({ (button) in
            button.setTitle(R.string.localizable.register_account(), for: .normal)
            button.addTarget(self, action: #selector(registerButtonClicked), for: .touchUpInside)
        }).layout(snapKitMaker: { (make) in
            make.top.equalTo(passwordTextField!.snp.bottom).offset(7)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(60)
            make.left.equalTo(passwordTextField!)
        })
        
        mailButton = UIButton().addTo(superView: shadowContainView).configure(buttonConfig).configure({ (button) in
            button.setTitle(R.string.localizable.forget_password_find_by_mail(), for: .normal)
            button.addTarget(self, action: #selector(mailButtonClicked), for: .touchUpInside)
        }).layout(snapKitMaker: { (make) in
            make.top.equalTo(passwordTextField!.snp.bottom).offset(7)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(60)
            make.right.equalTo(passwordTextField!)
        })
        
        loginButton = CommonButton(title: R.string.localizable.log_in()).addTo(superView: shadowContainView).configure({ (button) in
            button.addTarget(self, action: #selector(loginButtonClicked), for: .touchUpInside)
        }).layout(snapKitMaker: { (make) in
            make.size.equalTo(CGSize(width: 212, height: 42))
            make.top.equalTo(mailButton!.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        })
        
        let thirdLoginButtonConfig = {(button: AdjustLayoutButton) in
            button.titleLabel?.font = UIFont.size11
            button.setTitleColor(R.clr.appColor._844501(), for: .normal)
            button.padding = 5
            button.contentLayout = .imageTopTitleBottom
        }
//        twitterButton = AdjustLayoutButton().addTo(superView: containView).configure { (button) in
//            button.setImage(R.image.setting_Twitter(), for: .normal)
//            button.setTitle("Twitter", for: .normal)
//        }.configure(thirdLoginButtonConfig).layout { (make) in
//            make.top.equalTo(shadowContainView.snp.bottom).offset(20)
//            make.centerX.equalToSuperview()
//            make.size.equalTo(CGSize(width: 60, height: 60))
//        }
        
        facebookButton = AdjustLayoutButton().addTo(superView: containView).configure { (button) in
            button.setImage(R.image.general_facebook(), for: .normal)
            button.setTitle("Facebook", for: .normal)
            button.tag = SignPlatform.facebook.rawValue
            button.addTarget(self, action: #selector(thirdSignButtonClicked(_:)), for: .touchUpInside)
        }.configure(thirdLoginButtonConfig).layout { (make) in
            make.size.equalTo(CGSize(width: 60, height: 60))
            make.top.equalTo(shadowContainView.snp.bottom).offset(20)
            make.centerX.equalToSuperview().multipliedBy(0.4)
        }
        
        googleButton = AdjustLayoutButton().addTo(superView: containView).configure { (button) in
            button.setImage(R.image.general_google(), for: .normal)
            button.setTitle("Google+", for: .normal)
            button.tag = SignPlatform.google.rawValue
            button.addTarget(self, action: #selector(thirdSignButtonClicked(_:)), for: .touchUpInside)
        }.configure(thirdLoginButtonConfig).layout { (make) in
            make.size.equalTo(facebookButton!)
            make.top.equalTo(shadowContainView.snp.bottom).offset(20)
            make.centerX.equalToSuperview().multipliedBy(1.6)
        }
        
        containView.layout { (make) in
            make.bottom.equalTo(googleButton!.snp.bottom).offset(20)
        }
        
        addCloseButton(layout: { (make) in
            make.size.equalTo(closeButtonSize)
            make.top.equalTo(containView)
            make.left.equalTo(containView.snp.right).offset(5)
        }) { [unowned self] _ in
            self.delegate?.loginViewControllerDidCancel(self)
        }
    }
    
    @objc private func registerButtonClicked() {
        TransitionManager.presentInHidePresentingTransition(RegisterViewController.self, parameter: self)
    }
    
    @objc private func mailButtonClicked() {
        guard !UserManager.shared.mailInBinded.isEmpty else {
            AlertController.alert(title: R.string.localizable.account_not_bind_mail(), message: nil, from: self)
            return
        }
        BlockHUD.showLoading(inView: view)
        LoginModuleManager.resetPassword(byEmail: UserManager.shared.mailInBinded) { (result) in
            BlockHUD.hide(forView: self.view)
            switch result {
            case .success(_):
                AlertController.alert(title: R.string.localizable.send_success_check_mail(), message: nil, from: self)
            case .failure(.emailNotBindToUser):
                AlertController.alert(title: R.string.localizable.email_not_bind_user(), message: nil, from: self)
            case .failure(let error):
                self.defaultParseError(error)
            }
        }
    }
    
    @objc private func thirdSignButtonClicked(_ sender: AdjustLayoutButton) {
        let currentPlatform = UserManager.shared.loginPlatform /// 全局的一个登录平台枚举
        let buttonPlatform = SignPlatform(rawValue: sender.tag)! /// 当前类里的登录平台枚举，用于做button的tag
        guard currentPlatform != .app, currentPlatform == buttonPlatform.toSignInPlatform else {
            AlertController.alert(title: R.string.localizable.please_bind_first(), message: nil, from: self)
            return
        }
        switch buttonPlatform {
        case .facebook:
            facebookSignInService?.signIn()
        case .google:
            googleSignInService.signIn()
        default:
            break
        }
    }
    
    @objc private func loginButtonClicked() {
        guard let account = accountTextField?.text, !account.isEmpty else {
            AlertController.alert(title: R.string.localizable.input_account_and_id(), message: nil, from: self)
            return
        }
        guard let password = passwordTextField?.text, !password.isEmpty else {
            AlertController.alert(title: R.string.localizable.input_password(), message: nil, from: self)
            return
        }
        BlockHUD.showLoading(inView: view)
        login(account: account, password: password, platform: .app)
    }
    
    private func login(account: String, password: String, platform: SignInPlatformEnum) {
        LoginModuleManager.login(account: account, password: password, platform: platform) { [unowned self] (result) in
            BlockHUD.hide(forView: self.view)
            switch result {
            case .success(_):
                self.delegate?.loginViewControllerDidLoginSuccessful(self)
            case .failure(.accountNotExist):
                AlertController.alert(title: R.string.localizable.the_account_not_exist(), message: nil, from: self)
            case .failure(.passwordError):
                AlertController.alert(title: R.string.localizable.the_password_error(), message: nil, from: self)
            default:
                AlertController.alert(title: R.string.localizable.common_request_fail_retry(), message: nil, from: self)
            }
        }
    }
}

extension LoginViewController: RegisterViewControllerDelegate {
    func registerDidSuccessful() {
        TransitionManager.dismiss(animated: true) {
            self.delegate?.loginViewControllerDidLoginSuccessful(self)
        }
    }
}

extension LoginViewController: GoogleSignServiceDelegate, GoogleSignServiceUIDelegate {
    func sign(inWillDispath signIn: GoogleSignService) {
        BlockHUD.showLoading(inView: view)
    }
    
    func sign(_ signIn: GoogleSignService, present viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GoogleSignService, dismiss viewController: UIViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GoogleSignService, didSignFor openID: String, token: String) {
        login(account: openID, password: token, platform: .google)
    }
    
    func signDidCanceled(_ signIn: GoogleSignService) {
        BlockHUD.hide(forView: self.view)
    }
    
    func sign(_ signIn: GoogleSignService, didSignFailed: Error) {
        BlockHUD.hide(forView: self.view)
        AlertController.alert(title: R.string.localizable.authorize_failed(), message: nil, from: self)
    }
}

extension LoginViewController: FacebookSignServiceDelegate {
    func signDidCanceled(_ signIn: FacebookSignService) {
        BlockHUD.hide(forView: view)
    }
    
    func sign(_ signIn: FacebookSignService, didSignFor openID: String, token: String) {
        login(account: openID, password: token, platform: .facebook)
    }
    
    func sign(_ signIn: FacebookSignService, didSignFailed: Error) {
        BlockHUD.hide(forView: self.view)
        AlertController.alert(title: R.string.localizable.authorize_failed(), message: nil, from: self)
    }
}

