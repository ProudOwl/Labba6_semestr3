#include <iostream>
#include <pqxx/pqxx>
#include <string>
#include <vector>
#include <iomanip>
#include <chrono>
#include <sstream>

using namespace std;

class FoodOrderDB {
private:
    string connection_string;

public:
    FoodOrderDB(const string& conn_str) : connection_string(conn_str) {}

    void execute_command(const string& sql, const string& desc) {
        try {
            pqxx::connection C(connection_string);
            pqxx::work W(C);
            W.exec(sql);
            W.commit();
            cout << "[SUCCESS] " << desc << endl;
        } catch (const exception &e) {
            cerr << "[ERROR] " << desc << ": " << e.what() << endl;
        }
    }

    void print_query_results(const string& sql, const string& title) {
        try {
            pqxx::connection C(connection_string);
            pqxx::nontransaction N(C);
            pqxx::result R(N.exec(sql));

            cout  << title << endl;
            if (R.empty()) {
                cout << "No data found." << endl;
                return;
            }

            for (int col = 0; col < R.columns(); ++col) {
                cout << setw(25) << left << R.column_name(col);
            }
            cout << endl << string(R.columns() * 25, '-') << endl;

            for (const auto& row : R) {
                for (const auto& field : row) {
                    cout << setw(25) << left << field.c_str();
                }
                cout << endl;
            }
        } catch (const exception &e) {
            cerr << "Query execution error: " << e.what() << endl;
        }
    }
};

int main() {
    string conn_str = "dbname=food_order_db user=postgres password=postgres host=localhost port=5432";
    FoodOrderDB db(conn_str);

    // 1. INSERT
    db.execute_command(
        "INSERT INTO customers (email, name, phone, address) "
        "VALUES ('alex@example.com', 'Alex Johnson', '555-0101', '123 Main St');",
        "Inserting customer Alex Johnson with natural key (email)"
    );

    // 2. UPDATE (рейтинг ресторана)
    db.execute_command(
        "UPDATE restaurants SET rating = 4.8 "
        "WHERE name = 'Bella Italia' AND address = '321 Pasta Lane';",
        "Updating restaurant rating"
    );

    // 3. SELECT с WHERE (блюда дешевле $15)
    db.print_query_results(
        "SELECT item_name, price, category "
        "FROM menu_items "
        "WHERE price < 15.00;",
        "Menu items under $15"
    );

    // 4. INNER JOIN (заказы с именами клиентов)
    db.print_query_results(
        "SELECT c.name as Customer, o.order_date, o.total_amount "
        "FROM orders o "
        "JOIN customers c ON o.customer_email = c.email;",
        "Orders with Customer Names"
    );

    // 5. LEFT JOIN (рестораны без заказов)
    db.print_query_results(
        "SELECT r.name, r.address "
        "FROM restaurants r "
        "LEFT JOIN orders o ON r.name = o.restaurant_name AND r.address = o.restaurant_address "
        "WHERE o.customer_email IS NULL;",
        "Restaurants with no orders"
    );

    // 6. Агрегатная функция COUNT + GROUP BY (статистика по ресторанам)
    db.print_query_results(
        "SELECT r.name, COUNT(o.customer_email) as order_count "
        "FROM restaurants r "
        "JOIN orders o ON r.name = o.restaurant_name AND r.address = o.restaurant_address "
        "GROUP BY r.name, r.address;",
        "Number of orders per restaurant"
    );

    // 7. Сложный JOIN (3+ таблицы) + Сортировка
    db.print_query_results(
        "SELECT c.name as Customer, r.name as Restaurant, o.total_amount, o.order_date "
        "FROM orders o "
        "JOIN customers c ON o.customer_email = c.email "
        "JOIN restaurants r ON o.restaurant_name = r.name AND o.restaurant_address = r.address "
        "ORDER BY o.total_amount DESC;",
        "Orders with Customer and Restaurant details"
    );

    // 8. HAVING (фильтрация по агрегированным данным)
    db.print_query_results(
        "SELECT r.name, AVG(o.total_amount) as avg_order_value "
        "FROM restaurants r "
        "JOIN orders o ON r.name = o.restaurant_name AND r.address = o.restaurant_address "
        "GROUP BY r.name, r.address "
        "HAVING AVG(o.total_amount) > 25.00;",
        "Restaurants with average order value > $25"
    );

    // 9. Подзапрос (блюда из ресторанов с высоким рейтингом)
    db.print_query_results(
        "SELECT item_name, price, category "
        "FROM menu_items "
        "WHERE (restaurant_name, restaurant_address) IN ("
        "    SELECT name, address FROM restaurants WHERE rating >= 4.5"
        ");",
        "Menu items from highly rated restaurants"
    );

    // 10. DELETE (удаление клиента)
    db.execute_command(
        "DELETE FROM customers WHERE email = 'alex@example.com';",
        "Cleaning up: Deleting customer Alex Johnson"
    );

    return 0;
}
