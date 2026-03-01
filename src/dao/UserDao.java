package dao;

import malgnsoft.db.*;

public class UserDao extends DataObject {
    public UserDao() {
        this.table = "tb_user";
        this.PK = "id";
    }

    public DataSet findByEmail(String email) {
        return this.find("email = ?", new Object[]{email});
    }

    public DataSet checkLogin(String email, String passwd) {
        return this.find("email = ? AND passwd = ?", new Object[]{email, passwd});
    }

    public boolean isDuplicateEmail(String email) {
        DataSet rs = this.find("email = ?", new Object[]{email});
        return rs.next();
    }
}
