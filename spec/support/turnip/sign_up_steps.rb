# encoding: utf-8
module Turnip
  module SignUpSteps
    step "que acesso a página de signup" do
      visit root_path

      click_link 'Criar conta'

      expect(page).to have_content 'Crie sua conta'
    end

    step "informo os dados para o cadastro de pais" do
      VCR.use_cassette('signup_parent') do
        expect(page).to have_content "Dados pessoais"

        fill_in 'E-mail', with: 'clark@example.com'
        fill_in 'Senha', with: '11223344'
        fill_in 'Confirme a senha', with: '11223344'
        fill_mask "Celular", with: "(31) 94361177"

        check "Pais"

        fill_mask "CPF", with: "729.785.662-21"
        fill_in "Código do aluno", with: "1932"

        sleep 2
      end

      expect(page).to have_content "Alunos"

      within "table" do
        within "tbody tr:nth-child(1)" do
          click_on "ADRIANO ROQUE"
          expect(page).to have_content "ADRIANO ROQUE"
          expect(page).to have_content "544"
        end

        within "tbody tr:nth-child(2)" do
          click_on "ABNER ROCHA"
          expect(page).to have_content "ABNER ROCHA"
          expect(page).to have_content "1932"
        end
      end

      click_button 'Confirmar e acessar o sistema'
    end

    step "deverei ser logado ao sistema" do
      expect(page).to have_text 'Bem-vindo! Você se registrou com sucesso.'

      user = User.last

      expect(user.email).to eq "clark@example.com"
      expect(user.students.pluck(:name)).to eq(["ADRIANO ROQUE", "ABNER ROCHA"])
    end

    step "informo os dados para o acesso do aluno" do
      expect(page).to have_content "Dados pessoais"

      fill_in 'E-mail', with: 'mary@mary.com'
      fill_in 'Senha', with: '11223344'
      fill_in 'Confirme a senha', with: '11223344'

      check "Aluno"

      click_on "Confirmar e acessar o sistema"
    end

    step "deverei ver a mensagem de acesso solicitado" do
      sleep 3
      expect(page).to have_content "Notificamos o responsável da sua unidade escolar sobre sua solicitação. Em breve você receberá um e-mail com o seu acesso."
    end

    step "o login não poderá ser realizado enquanto o acesso estiver pendente" do
      fill_in 'Informe o Nome de usuário, E-mail, Celular ou CPF', with: 'mary@mary.com'
      fill_in 'Senha', with: '11223344'

      click_on 'Acessar'

      expect(page).to have_content 'A sua conta não foi ativada ainda.'
    end

    step "informo os dados para o acesso do servidor" do
      fill_in 'E-mail', with: 'tony@stark.com'
      fill_in 'Senha', with: '11223344'
      fill_in 'Confirme a senha', with: '11223344'

      check "Servidor"

      click_on "Confirmar e acessar o sistema"
    end

    step "o servidor não poderá logar enquanto o acesso estiver pendente" do
      fill_in 'Informe o Nome de usuário, E-mail, Celular ou CPF', with: 'tony@stark.com'
      fill_in 'Senha', with: '11223344'

      click_on 'Acessar'

      expect(page).to have_content 'A sua conta não foi ativada ainda.'
    end

    step "informo os dados para o acesso de pai, aluno e servidor" do
      VCR.use_cassette('signup_parent') do
        expect(page).to have_content "Dados pessoais"

        fill_in 'E-mail', with: 'johnstuart@example.com'
        fill_in 'Senha', with: '11223344'
        fill_in 'Confirme a senha', with: '11223344'
        fill_mask "Celular", with: "(31) 94361177"

        check "Servidor"
        check "Aluno"
        check "Pais"

        fill_mask "CPF", with: "729.785.662-21"
        fill_in "Código do aluno", with: "1932"

        sleep 2
      end

      expect(page).to have_content "Alunos"

      within "table" do
        within "tbody tr:nth-child(1)" do
          click_on "ADRIANO ROQUE"
          expect(page).to have_content "ADRIANO ROQUE"
          expect(page).to have_content "544"
        end

        within "tbody tr:nth-child(2)" do
          click_on "ABNER ROCHA"
          expect(page).to have_content "ABNER ROCHA"
          expect(page).to have_content "1932"
        end
      end

      click_button 'Confirmar e acessar o sistema'
    end

    step "o usuário deverá ter os perfis vinculados a sua conta" do
      student = roles(:student)
      secretary = roles(:secretary)
      parent = roles(:parent)

      user = User.last

      expect(user.email).to eq 'johnstuart@example.com'
      expect(user.user_roles.count).to eq 3
      expect(user.roles).to include student
      expect(user.roles).to include secretary
      expect(user.roles).to include parent
    end
  end
end

RSpec.configure do |config|
  config.include Turnip::SignUpSteps
end
