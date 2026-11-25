package hei.school;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class LogSmsSender implements SmsSender {

    @Value("${sms.simulate-failure:false}")
    private boolean simulateFailure;

    @Override
    public void send(String phone, String message) {
        if (simulateFailure) {
            throw new IllegalStateException("Fournisseur SMS indisponible (simulation)");
        }
        System.out.println("[SMS] " + phone + " : " + message);
    }
}
