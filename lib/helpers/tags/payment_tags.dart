// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
const kCardPaymentOptions = <String>{
  // Debit cards
  'debit_cards',
  'bancomat', 'bancontact', 'cb', 'girocard', 'gpn_debit',
  'laser', 'maestro', 'postfinance_card', 'v_pay', 'visa_debit',
  'mastercard_debit', 'visa_electron',
  // Credit cards
  'credit_cards',
  'american_express', 'diners_club', 'discover_card', 'jcb',
  'mastercard', 'unionpay', 'visa', 'mir', 'belkart', 'pro100',
  // Contactless
  'contactless',
  'mastercard_contactless', 'paypass', 'visa_contactless',
  'girocard_contactless', 'quickpass', 'QUICpay',
  'apple_pay', 'google_pay'
  // Digital wallets
  'troika', 'wechat', 'alipay', 'blik', 'gcash', 'touchngo',
  'huawei_pay', 'interac', 'line_pay', 'mipay', 'samsung_pay',
  'satispay', 'swish', 'twint',
};

const kNotCards = {
  'cash', 'notes', 'coins', 'cheque',
  'bitcoin', 'cryptocurrencies', 'bitcoincash', 'litecoin',
  'none', 'others', 'app', 'sms', 'wire_transfer', 'prepaid_ticket',
};
