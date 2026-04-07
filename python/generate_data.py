import pandas as pd
import numpy as np
import random
from faker import Faker
import os

fake = Faker('en_IN')
np.random.seed(42)
random.seed(42)

# ── CONFIG ──────────────────────────────────────────
NUM_CUSTOMERS = 10000
NUM_TRANSACTIONS = 100000

cities = ['Mumbai', 'Delhi', 'Bangalore', 'Chennai', 'Hyderabad']
city_weights = [0.30, 0.25, 0.20, 0.15, 0.10]

card_tiers = ['Blue', 'Silver', 'Gold', 'Platinum']
tier_weights = [0.50, 0.25, 0.15, 0.10]
tier_limits = {'Blue': 50000, 'Silver': 150000, 'Gold': 300000, 'Platinum': 700000}
tier_annual_fee = {'Blue': 0, 'Silver': 999, 'Gold': 2499, 'Platinum': 9999}

occupations = ['Salaried', 'Business Owner', 'Self-Employed', 'Student', 'Retired']
occ_weights = [0.45, 0.25, 0.15, 0.10, 0.05]

categories = ['Bills', 'Grocery', 'Food & Dining', 'Fuel', 'Shopping',
              'Travel', 'Entertainment', 'Healthcare', 'Education', 'Others']
cat_weights = [0.20, 0.18, 0.15, 0.12, 0.10, 0.08, 0.06, 0.05, 0.04, 0.02]

channels = ['Swipe', 'Chip', 'Online']
channel_weights = [0.63, 0.31, 0.06]

# ── GENERATE CUSTOMERS ───────────────────────────────
print("Generating customers...")
customers = []
for i in range(NUM_CUSTOMERS):
    tier = random.choices(card_tiers, tier_weights)[0]
    city = random.choices(cities, city_weights)[0]
    occupation = random.choices(occupations, occ_weights)[0]
    age = random.randint(21, 65)
    credit_limit = tier_limits[tier] * random.uniform(0.8, 1.2)
    credit_score = random.randint(600, 900)
    tenure_months = random.randint(1, 84)

    customers.append({
        'customer_id': f'CUST{str(i+1).zfill(5)}',
        'name': fake.name(),
        'age': age,
        'city': city,
        'occupation': occupation,
        'card_tier': tier,
        'credit_limit': round(credit_limit, 2),
        'credit_score': credit_score,
        'tenure_months': tenure_months,
        'annual_fee': tier_annual_fee[tier],
        'is_active': random.choices([1, 0], [0.88, 0.12])[0]
    })

customers_df = pd.DataFrame(customers)

# ── GENERATE TRANSACTIONS ────────────────────────────
print("Generating transactions...")
transactions = []
start_date = pd.Timestamp('2023-01-01')
end_date = pd.Timestamp('2024-12-31')

for i in range(NUM_TRANSACTIONS):
    customer = customers_df.sample(1).iloc[0]
    tier = customer['card_tier']
    category = random.choices(categories, cat_weights)[0]
    channel = random.choices(channels, channel_weights)[0]

    base_amount = {
        'Blue': random.uniform(100, 3000),
        'Silver': random.uniform(500, 8000),
        'Gold': random.uniform(1000, 20000),
        'Platinum': random.uniform(2000, 50000)
    }[tier]

    if category in ['Travel', 'Shopping']:
        base_amount *= random.uniform(1.5, 3.0)
    elif category in ['Bills', 'Fuel']:
        base_amount *= random.uniform(0.5, 1.2)

    amount = round(base_amount, 2)
    transaction_date = start_date + pd.Timedelta(
        days=random.randint(0, (end_date - start_date).days)
    )

    interest = round(amount * 0.035, 2) if random.random() < 0.30 else 0.0
    is_defaulted = 1 if random.random() < 0.03 else 0

    transactions.append({
        'transaction_id': f'TXN{str(i+1).zfill(7)}',
        'customer_id': customer['customer_id'],
        'transaction_date': transaction_date.strftime('%Y-%m-%d'),
        'category': category,
        'channel': channel,
        'amount': amount,
        'interest_charged': interest,
        'city': customer['city'],
        'card_tier': tier,
        'is_defaulted': is_defaulted
    })

transactions_df = pd.DataFrame(transactions)

# ── SAVE FILES ───────────────────────────────────────
os.makedirs('../data', exist_ok=True)
customers_df.to_csv('../data/customers.csv', index=False)
transactions_df.to_csv('../data/transactions.csv', index=False)

print(f"\n✓ customers.csv  → {len(customers_df):,} rows")
print(f"✓ transactions.csv → {len(transactions_df):,} rows")
print("\nSample transaction data:")
print(transactions_df.head(3).to_string())
print("\nData generation complete! Check your /data folder.")