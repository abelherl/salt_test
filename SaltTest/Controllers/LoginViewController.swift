//
//  ViewController.swift
//  SaltTest
//
//  Created by Abel Herlambang on 15/02/24.
//

import UIKit

let email = UITextField()
let password = UITextField()

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        let spacer = UIView()
        let spacerConstraint = spacer.heightAnchor.constraint(equalToConstant: .greatestFiniteMagnitude)
        spacerConstraint.priority = .defaultLow
        spacerConstraint.isActive = true
        
        email.placeholder = "Email"
        email.borderStyle = UITextField.BorderStyle.roundedRect
        email.translatesAutoresizingMaskIntoConstraints = false
        email.returnKeyType = UIReturnKeyType.done
        email.autocorrectionType = .no
        email.autocapitalizationType = .none
        email.spellCheckingType = .no
        
        password.placeholder = "Password"
        password.borderStyle = UITextField.BorderStyle.roundedRect
        password.translatesAutoresizingMaskIntoConstraints = false
        password.returnKeyType = UIReturnKeyType.done
        password.autocorrectionType = .no
        password.autocapitalizationType = .none
        password.spellCheckingType = .no
        password.obsc
        
        let loginButton = UIButton()
        loginButton.setTitleColor(.systemBlue, for: .normal)
        loginButton.setTitle("Login", for: .normal)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [email, password, loginButton, spacer])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }
    
    @objc func login() {
        let isEmptyEmail = email.text?.isEmpty ?? true
        let isEmptyPassword = password.text?.isEmpty ?? true
        
        if isEmptyEmail || isEmptyPassword {
            if isEmptyEmail {
                email.isError()
            } else {
                let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
                let isValidEmail = emailPred.evaluate(with: email.text)
                
                if !isValidEmail {
                    email.isError()
                    return
                }
            }
            if isEmptyPassword{
                password.isError()
            }
            return
        }
        
        APIService().login(email: email.text!, password: password.text!) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    print("Login successful. Token: \(token)")
                    let defaults = UserDefaults.standard
                    defaults.set(token, forKey: "token")
                case .failure(let error):
                    print("Login failed with error: \(error)")
                    let alert = UIAlertController(title: "Login Failed", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UITextField {
    func isError() {
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "shadowColor")
        animation.fromValue = UIColor.gray
        animation.toValue = UIColor.red.cgColor
        animation.duration = 0.4
        animation.autoreverses = true
        self.layer.add(animation, forKey: "")
        
        let shake: CABasicAnimation = CABasicAnimation(keyPath: "position")
        shake.duration = 0.07
        shake.repeatCount = 3
        shake.autoreverses = true
        shake.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        shake.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        self.layer.add(shake, forKey: "position")
    }
}

