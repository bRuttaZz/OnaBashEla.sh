FROM alpine:latest
ENV TERM=xterm-256color
RUN apk add --update ncurses bash bc
COPY ona-bash-ela.sh /ona-bash-ela.sh
RUN chmod +x /ona-bash-ela.sh
CMD ["/ona-bash-ela.sh"]
